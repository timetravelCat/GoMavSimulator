#pragma once

#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/core/defs.hpp>
#include <godot_cpp/variant/variant.hpp>
#include <godot_cpp/variant/array.hpp>
#include <godot_cpp/variant/dictionary.hpp>
#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/templates/vector.hpp>
#include <godot_cpp/templates/rb_map.hpp>
#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/godot.hpp>
#include "include/serial/serial.h"
#include <thread>
#include <atomic>
#include <memory>

using namespace serial;
using namespace godot;

class SerialPort : public Node
{
    GDCLASS(SerialPort, Node);

    Serial *serial;
    std::shared_ptr<std::thread> thread;
    std::atomic<bool> is_thread_running{false};
    std::atomic<bool> request_stop_thread{false};
    bool fine_working = false;
    int monitoring_interval = 10000;
    bool monitoring_should_exit = false;
    String error_message = "";

    void _data_received(const PackedByteArray &buf);
    static void _thread_func(void *p_user_data);

public:
    enum ByteSize
    {
        BYTESIZE_5 = fivebits,
        BYTESIZE_6 = sixbits,
        BYTESIZE_7 = sevenbits,
        BYTESIZE_8 = eightbits,
    };
    enum Parity
    {
        PARITY_NONE = parity_none,
        PARITY_ODD = parity_odd,
        PARITY_EVEN = parity_even,
        PARITY_MARK = parity_mark,
        PARITY_SPACE = parity_space,
    };
    enum StopBits
    {
        STOPBITS_1 = stopbits_one,
        STOPBITS_2 = stopbits_two,
        STOPBITS_1P5 = stopbits_one_point_five,
    };
    enum FlowControl
    {
        FLOWCONTROL_NONE = flowcontrol_none,
        FLOWCONTROL_SOFTWARE = flowcontrol_software,
        FLOWCONTROL_HARDWARE = flowcontrol_hardware,
    };

    SerialPort(const String &port = "",
               uint32_t baudrate = 9600,
               uint32_t timeout = 0,
               ByteSize bytesize = BYTESIZE_8,
               Parity parity = PARITY_NONE,
               StopBits stopbits = STOPBITS_1,
               FlowControl flowcontrol = FLOWCONTROL_NONE);

    ~SerialPort();

    static Dictionary list_ports();
    bool is_in_error() { return is_open() && !fine_working; }
    inline String get_last_error() { return error_message; }
    void _on_error(const String &where, const String &what);
    Error start_monitoring(uint64_t interval_in_usec = 10000);
    void stop_monitoring();
    Error open(String port = "");
    bool is_open() const;
    void close();
    size_t available();
    bool wait_readable();
    void wait_byte_times(size_t count);
    PackedByteArray read_raw(size_t size = 1);
    String read_str(size_t size = 1, bool utf8_encoding = false);
    size_t write_raw(const PackedByteArray &data);
    size_t write_str(const String &data, bool utf8_encoding = false);
    String read_line(size_t size = 65535, String eol = "\n", bool utf8_encoding = false);
    PackedStringArray read_lines(size_t size = 65535, String eol = "\n", bool utf8_encoding = false);
    Error set_port(const String &port);
    String get_port() const;
    Error set_timeout(uint32_t timeout);
    uint32_t get_timeout() const;
    Error set_baudrate(uint32_t baudrate);
    uint32_t get_baudrate() const;
    Error set_bytesize(ByteSize bytesize);
    ByteSize get_bytesize() const;
    Error set_parity(Parity parity);
    Parity get_parity() const;
    Error set_stopbits(StopBits stopbits);
    StopBits get_stopbits() const;
    Error set_flowcontrol(FlowControl flowcontrol);
    FlowControl get_flowcontrol() const;
    Error flush();
    Error flush_input();
    Error flush_output();
    Error send_break(int duration);
    Error set_break(bool level = true);
    Error set_rts(bool level = true);
    Error set_dtr(bool level = true);
    bool wait_for_change();
    bool get_cts();
    bool get_dsr();
    bool get_ri();
    bool get_cd();
protected:
    String _to_string() const;
    static void _bind_methods();
};

VARIANT_ENUM_CAST(SerialPort::ByteSize);
VARIANT_ENUM_CAST(SerialPort::Parity);
VARIANT_ENUM_CAST(SerialPort::StopBits);
VARIANT_ENUM_CAST(SerialPort::FlowControl);