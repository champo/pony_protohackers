
trait Blebler 
  fun ble(): String

// 2 "marker values"
primitive OpenedDoor is Blebler 
   fun ble(): String =>
      "closed"

primitive ClosedDoor is Blebler 
   fun ble(): String =>
      "closed"

// An "enumeration" type
type DoorState is (OpenedDoor | ClosedDoor)

// A collection of functions
primitive BasicMath
  fun add(a: U64, b: U64): U64 =>
    a + b

  fun multiply(a: U64, b: U64): U64 =>
    a * b

actor Main
  new create(env: Env) =>
    let doorState: DoorState ref = ref ClosedDoor
    env.out.print("Is door open? " + ble(doorState))
    env.out.print("2 + 3 = " + BasicMath.add(2,3).string())

  fun ble(a: Blebler ref): String =>
     a.ble()