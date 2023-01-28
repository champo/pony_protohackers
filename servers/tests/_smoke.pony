use "pony_test"
use "net"
use "../"

actor NulLogger
  be log (msg: String) =>
    None

class iso _TestOpenClose is UnitTest
  let port: String = "8989"

  fun name(): String => "p01/open then close"

  fun apply(h: TestHelper) =>
    h.long_test(1_000_000_000)
    h.expect_action("connected")
    h.expect_action("closed")

    h.dispose_when_done(
      TCPListener(
        TCPListenAuth(h.env.root),
        recover MyTCPListenNotify(NulLogger) end, 
        "", 
        port
      )
    )

    let conn = TCPConnection(TCPConnectAuth(h.env.root),
      object iso is TCPConnectionNotify

        fun ref connected(conn: TCPConnection ref) =>
          h.complete_action("connected")
          conn.close()

        fun ref closed(conn: TCPConnection ref) =>
          h.complete_action("closed")

        fun ref received(conn: TCPConnection ref, data: Array[U8] iso, times: USize): Bool =>
          h.fail("Received data")
          true

        fun ref connect_failed(conn: TCPConnection ref) =>
          h.fail("failed to connect")
      end
      , 
      "", 
      port
    )

    h.dispose_when_done(conn)


class iso _TestWriteNulAtEnd is UnitTest
  let port: String = "8989"

  fun name(): String => "p01/write nul at end"

  fun apply(h: TestHelper) =>
    h.long_test(1_000_000_000)
    h.expect_action("connected")
    h.expect_action("receive")
    h.expect_action("closed")

    h.dispose_when_done(
      TCPListener(
        TCPListenAuth(h.env.root),
        recover MyTCPListenNotify(OutStreamLogger(h.env.out)) end, 
        "", 
        port
      )
    )

    let conn = TCPConnection(TCPConnectAuth(h.env.root),
      object iso is TCPConnectionNotify

        fun ref connected(conn: TCPConnection ref) =>
          conn.write("nul at end\0")
          h.complete_action("connected")

        fun ref closed(conn: TCPConnection ref) =>
          h.complete_action("closed")

        fun ref received(conn: TCPConnection ref, data: Array[U8] iso, times: USize): Bool =>
          h.assert_array_eq[U8]("nul at end\0", consume data)
          h.complete_action("receive")

          conn.close()

          true

        fun ref connect_failed(conn: TCPConnection ref) =>
          h.fail("failed to connect")
      end
      , 
      "", 
      port
    )

    h.dispose_when_done(conn)

class iso _TestWriteNulAtMiddle is UnitTest
  let port: String = "8989"

  fun name(): String => "p01/write nul at middle"

  fun apply(h: TestHelper) =>
    h.long_test(1_000_000_000)
    h.expect_action("connected")
    h.expect_action("receive")
    h.expect_action("closed")

    h.dispose_when_done(
      TCPListener(
        TCPListenAuth(h.env.root),
        recover MyTCPListenNotify(OutStreamLogger(h.env.out)) end, 
        "", 
        port
      )
    )

    let conn = TCPConnection(TCPConnectAuth(h.env.root),
      object iso is TCPConnectionNotify

        fun ref connected(conn: TCPConnection ref) =>
          conn.write("nul at\0middle")
          h.complete_action("connected")

        fun ref closed(conn: TCPConnection ref) =>
          h.complete_action("closed")

        fun ref received(conn: TCPConnection ref, data: Array[U8] iso, times: USize): Bool =>
          h.assert_array_eq[U8]("nul at\0middle", consume data)
          h.complete_action("receive")

          conn.close()

          true

        fun ref connect_failed(conn: TCPConnection ref) =>
          h.fail("failed to connect")
      end
      , 
      "", 
      port
    )

    h.dispose_when_done(conn)

class iso _TestWriteTwice is UnitTest
  let port: String = "8989"

  fun name(): String => "p01/write twice"

  fun apply(h: TestHelper) =>
    h.long_test(1_000_000_000)
    h.expect_action("connected")
    h.expect_action("receive_first")
    h.expect_action("receive_second")
    h.expect_action("closed")

    h.dispose_when_done(
      TCPListener(
        TCPListenAuth(h.env.root),
        recover MyTCPListenNotify(OutStreamLogger(h.env.out)) end, 
        "", 
        port
      )
    )

    let conn = TCPConnection(TCPConnectAuth(h.env.root),
      object iso is TCPConnectionNotify

        var first_received: Bool = false

        fun ref connected(conn: TCPConnection ref) =>
          conn.write("first part")
          h.complete_action("connected")

        fun ref closed(conn: TCPConnection ref) =>
          h.complete_action("closed")

        fun ref received(conn: TCPConnection ref, data: Array[U8] iso, times: USize): Bool =>
          if not first_received then
            h.assert_array_eq[U8]("first part", consume data)
            h.complete_action("receive_first")

            conn.write("second part\0")

            first_received = true
          else
            h.assert_array_eq[U8]("second part\0", consume data)
            h.complete_action("receive_second")

            conn.close()
          end
          
          true

        fun ref connect_failed(conn: TCPConnection ref) =>
          h.fail("failed to connect")
      end
      , 
      "", 
      port
    )

    h.dispose_when_done(conn)
