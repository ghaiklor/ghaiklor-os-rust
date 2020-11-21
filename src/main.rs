#![no_std]
#![no_main]
#![feature(custom_test_frameworks)]
#![test_runner(ghaiklor_os_rust::test_runner)]
#![reexport_test_harness_main = "test_main"]

extern crate alloc;

use alloc::boxed::Box;
use alloc::vec::Vec;
use bootloader::entry_point;
use bootloader::BootInfo;
use core::panic::PanicInfo;
use ghaiklor_os_rust::allocator;
use ghaiklor_os_rust::memory;
use ghaiklor_os_rust::memory::BootInfoFrameAllocator;
use ghaiklor_os_rust::println;
use ghaiklor_os_rust::task::{simple_executor::SimpleExecutor, Task};
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
    let mut mapper = unsafe { memory::init(phys_mem_offset) };
    let mut frame_allocator = unsafe { BootInfoFrameAllocator::init(&boot_info.memory_map) };

    allocator::init_heap(&mut mapper, &mut frame_allocator).expect("heap initialization failed");
    let heap_value = Box::new(41);
    println!("heap value at {:p}", heap_value);
    let mut vector = Vec::new();
    for i in 0..500 {
        vector.push(i);
    }
    println!("vector at {:p}", vector.as_slice());

    let mut executor = SimpleExecutor::new();
    executor.spawn(Task::new(example_task()));
    executor.run();

    #[cfg(test)]
    test_main();

    println!("It did not crash :)");
    ghaiklor_os_rust::hlt_loop();
}

async fn async_number() -> u32 {
    42
}

async fn example_task() {
    let number = async_number().await;
    println!("async number: {}", number);
}
