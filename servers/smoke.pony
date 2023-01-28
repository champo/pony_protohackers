use "net"

class SmokeConnectionListener is TCPConnectionNotify
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
    logger.log("Got " + data.size().string() + " bytes")
    conn.write_final(consume data)

    true

  fun ref connect_failed(conn: TCPConnection ref) =>
    None

class Smoke is TCPListenNotify
  let logger: Logger

  new create(logger': Logger) =>
    logger = logger'

  fun ref connected(listen: TCPListener ref): TCPConnectionNotify iso^ =>
    recover SmokeConnectionListener(logger) end

  fun ref not_listening(listen: TCPListener ref) =>
    None
