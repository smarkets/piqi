-module(add_person).
-compile(export_all).

-include("addressbook.hrl").


% Main function: Reads the entire address book from a file,
% adds one person based on user input, then writes it back out to the same
% file.
run([Argv0, Filename]) ->
    AddressBook =
        % Read the existing address book.
        case file:read_file(Filename) of
            {ok, InBytes} ->
                Buf = {'block', InBytes},
                try
                    addressbook:parse_address_book(Buf)
                catch
                    {'piqirun_error', _Reason} ->
                        io:format("Failed to parse address book.\n"),
                        halt(1)
                end;
            {error, _} ->
                io:format("~s: File not found.  Creating a new file.~n", [Argv0]),
                % NOTE: as repeated fields are initialized to [] by default,
                % there is no need to do that explicitly (i.e. "person = []")
                #addressbook_address_book{}
        end,

    % Add an address.
    NewAddressBook = prompt_for_address(AddressBook),

    % Write the new address book back to disk.

    % NOTE: specifying -1 as the field code has a special meaning: it tells
    % generator not to generate the header (code/tag/len) -- just generate the
    % contents
    OutBytes = addressbook:gen_address_book('undefined', NewAddressBook),
    ok = file:write_file(Filename, OutBytes);

run(_) ->
    halt(1).



% This function fills in a Person message based on user input.
prompt_for_address(AddressBook) ->
    print_endline("Enter person ID number: "),
    Id = list_to_integer(read_line()),

    print_endline("Enter name: "),
    Name = read_line(),

    print_endline("Enter email address (blank for none): "),
    Email =
        case read_line() of
            "" -> 'undefined';
            X -> X
        end,

    print_endline("Enter a phone number (or leave blank to finish): "),
    PhoneNumbers = read_phone_numbers(),
    Person = #addressbook_person{
        id = Id,
        name = Name,
        email = Email,
        phone = PhoneNumbers
    },
    % AddressBook
    #addressbook_address_book{
        person = AddressBook#addressbook_address_book.person ++ [Person]
    }.


read_phone_numbers() ->
    read_phone_numbers([]).

read_phone_numbers(Accu) ->
    case read_line() of
        "" -> lists:reverse(Accu);
        Number ->
            PhoneType = read_phone_type(),
            Res = #addressbook_person_phone_number{
                number = Number,
                type = PhoneType
            },
            read_phone_numbers([Res|Accu])
    end.


read_phone_type() ->
    print_endline("Is this a mobile, home, or work phone? "),
    case read_line() of
        "mobile" -> mobile;
        "home" -> home;
        "work" -> work;
        _ ->
            print_endline("Unknown phone type.  Using default."),
            'undefined'
    end.


print_endline(X) ->
    io:put_chars(X), io:nl().


read_line() ->
    io:get_line("") -- "\n". % chomp

