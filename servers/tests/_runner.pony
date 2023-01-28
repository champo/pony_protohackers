use "pony_test"
use "net"
use "../"

actor Main is TestList
  new create(env: Env) =>
    PonyTest(env, this)

  new make() =>
    None

  fun tag tests(test: PonyTest) =>
    test(_TestOpenClose)
    test(_TestWriteNulAtEnd)
    test(_TestWriteNulAtMiddle)
    test(_TestWriteTwice)