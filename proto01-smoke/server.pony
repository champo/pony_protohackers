use "net"

actor Logger
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

  fun ref closed(conn: TCPConnection ref) =>
    logger.log("Closed") 

  fun ref received(
    conn: TCPConnection ref,
    data: Array[U8] iso,
    times: USize)
    : Bool
  =>
    logger.log("Wrote " + data.size().string() + " bytes")
    conn.write(String.from_array(consume data))
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
    let logger = Logger(env.out)

    TCPListener(TCPListenAuth(env.root),
      recover MyTCPListenNotify(logger) end, "", "8989")