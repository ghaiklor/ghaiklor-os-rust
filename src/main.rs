#![no_std]
#![no_main]
#![feature(custom_test_frameworks)]
#![test_runner(ghaiklor_os_rust::test_runner)]
#![reexport_test_harness_main = "test_main"]

use bootloader::entry_point;
use bootloader::BootInfo;
use core::panic::PanicInfo;
use ghaiklor_os_rust::memory;
use ghaiklor_os_rust::memory::BootInfoFrameAllocator;
use ghaiklor_os_rust::println;
use x86_64::VirtAddr;

entry_point!(kernel_main);

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

fn kernel_main(boot_info: &'static BootInfo) -> ! {
    println!("Hello, World from macro");
    ghaiklor_os_rust::init();

    let phys_mem_offset = VirtAddr::new(boot_info.physical_memory_offset);
    let _mapper = unsafe { memory::init(phys_mem_offset) };
    let _frame_allocator = unsafe { BootInfoFrameAllocator::init(&boot_info.memory_map) };

    #[cfg(test)]
    test_main();

    println!("It did not crash :)");
    ghaiklor_os_rust::hlt_loop();
}
