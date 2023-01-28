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

class MyTCPConnectionNotify is TCPConnectionNotify
  let logger: Logger

  new create(logger': Logger) =>
    logger = logger'

  fun ref accepted(conn: TCPConnection ref) =>
    logger.log("Accepted")
    //conn.write("ble")

  fun ref closed(conn: TCPConnection ref) =>
    logger.log("Closed") 

  fun ref received(
    conn: TCPConnection ref,
    data: Array[U8] iso,
    times: USize)
    : Bool
  =>
    (let writeUpTo, let shouldClose) = try 
      (data.find(0)? + 1, true)
    else
      (data.size(), false)
    end

    logger.log("Got " + data.size().string() + " bytes, will write " + writeUpTo.string())
    data.trim_in_place(0, writeUpTo)
    conn.write_final(consume data)

    if shouldClose then
      logger.log("Closed due to null-byte")
      conn.close()
    end

    true

  fun ref connect_failed(conn: TCPConnection ref) =>
    None

class MyTCPListenNotify is TCPListenNotify
  let logger: Logger

  new create(logger': Logger) =>
    logger = logger'

  fun ref connected(listen: TCPListener ref): TCPConnectionNotify iso^ =>
    recover MyTCPConnectionNotify(logger) end

  fun ref not_listening(listen: TCPListener ref) =>
    None

actor Main
  new create(env: Env) =>
    let logger: Logger = OutStreamLogger(env.out)
    let port = try EnvVars(env.vars)("port")? else "8989" end

    TCPListener(TCPListenAuth(env.root),
      recover MyTCPListenNotify(logger) end, "", port)