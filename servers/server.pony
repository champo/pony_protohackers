use "net"
use "cli"

interface tag Logger
  be log(msg: String)

actor OutStreamLogger is Logger
   let out: OutStream

   new create(out': OutStream) =>
     out = out'

   be log(msg: String) =>
     out.print(msg)

actor Main
  new create(env: Env) =>
    let logger: Logger = OutStreamLogger(env.out)
    (let port, let problem) = try 
      let vars = EnvVars(env.vars)
      (vars("port")?, vars("problem")?)
    else 
      ("8989", "0")
    end

    TCPListener(TCPListenAuth(env.root),
      recover MyTCPListenNotify(logger) end, "", port)