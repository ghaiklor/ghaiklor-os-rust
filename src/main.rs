#![no_std]
#![no_main]
#![feature(custom_test_frameworks)]
#![test_runner(ghaiklor_os_rust::test_runner)]
#![reexport_test_harness_main = "test_main"]

use core::panic::PanicInfo;
use ghaiklor_os_rust::println;

#[cfg(not(test))]
#[panic_handler]
fn panic(info: &PanicInfo) -> ! {
    println!("{}", info);
    ghaiklor_os_rust::hlt_loop();
}

#[cfg(test)]
#[panic_handler]
fn panic(info: &PanicInfo) -> ! {
    ghaiklor_os_rust::test_panic_handler(info);
}

#[no_mangle]
pub extern "C" fn _start() -> ! {
    println!("Hello, World from macro");
    ghaiklor_os_rust::init();

    #[cfg(test)]
    test_main();

    ghaiklor_os_rust::hlt_loop();
}
