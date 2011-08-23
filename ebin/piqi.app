{application, piqi,
 [{description, "Piqi Library"},
  {vsn, "0.5.6"},
  {modules, [
        piqirun, piqirun_ext,
        piqi_tools, piqi_rpc_piqi, piqi_tools_piqi,
        piqi, piqi_app, piqi_sup]},
  {registered, [piqi_tools, piqi_sup]},
  {applications, [kernel, stdlib]},
  {mod, {piqi_app, []}},
  {env, []}]}.
