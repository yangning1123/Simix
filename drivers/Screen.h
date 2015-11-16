/*
 * 屏幕操作实现类，继承自VGA类
 *
 */ 

#ifndef SCREEN_H
#define SCREEN_H

#include <stdint.h>
#include "VGA.h"

namespace IO
{
    /* Hardware text mode color constants. */
    enum vga_color
    {
	COLOR_BLACK         = 0,
	COLOR_BLUE          = 1,
	COLOR_GREEN         = 2,
	COLOR_CYAN          = 3,
	COLOR_RED           = 4,
	COLOR_MAGENTA       = 5,
	COLOR_BROWN         = 6,
	COLOR_LIGHT_GREY    = 7,
	COLOR_DARK_GREY     = 8,
	COLOR_LIGHT_BLUE    = 9,
	COLOR_LIGHT_GREEN   = 10,
	COLOR_LIGHT_CYAN    = 11,
	COLOR_LIGHT_RED     = 12,
	COLOR_LIGHT_MAGENTA = 13,
	COLOR_LIGHT_BROWN   = 14,
	COLOR_WHITE         = 15
    };
    
    class Screen : public VGA
    {
    public:
	Screen()  = default;
	Screen(const uint8_t&, const uint8_t&);	
	~Screen() = default;

	virtual void clear_screen()      override;
	virtual void scroll_screen()     override;
	virtual void print_string(char*) override;
	
    protected:
	void move_cursor(const uint8_t, const uint8_t) const;

    private:
	static uint16_t* const video_address;       // 显存地址
	uint8_t cursor_x = 0;                       // 光标x轴位置
	uint8_t cursor_y = 0;                       // 光标y轴位置
    };
}


#endif /* SCREEN_H */
