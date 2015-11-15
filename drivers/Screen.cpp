/*
 * 屏幕操作实现类，继承自VGA类
 *
 */

#include <sys/io.h>
#include "Screen.h"

namespace IO
{
    uint16_t* Screen::video_address = (uint16_t*) 0xb8000;

    Screen::Screen(const uint8_t &x, const uint8_t &y) :
	VGA(),cursor_x(x), cursor_y(y)
    {
	move_cursor(x, y);
    }
    
    void Screen::clear_screen()
    {
	// 本质上就是在黑底上写满空白符
	uint8_t attribute = (COLOR_BLACK << 4) | COLOR_WHITE;
   	uint16_t blank = ' ' | (attribute << 8);
	for (uint16_t i = 0; i != 80 * 25; i++)
	    video_address[i] = blank;
	move_cursor(0, 0);
    }

    void Screen::scroll_screen()
    {

    }

    void Screen::print_string(char *str)
    {
	
    }

    void Screen::move_cursor(uint8_t x, uint8_t y) 
    {
	// note:(x,y)坐标，不是行和列
	uint16_t cursor_pos = y * 80 + x;
	outb(0x3D4, 0x0E);
	outb(0x3D5, (cursor_pos >> 8) & 0xFF);
	outb(0x3D4, 0x0F);
	outb(0x3D5, cursor_pos & 0xFF);
    }
}


















