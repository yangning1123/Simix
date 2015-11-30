/*
 * 屏幕操作实现类，继承自VGA类
 *
 */

#include <sys/io.h>
#include "Screen.h"

namespace IO
{
    uint16_t* const Screen::video_address = (uint16_t*) 0xb8000;
    const uint16_t Screen::blank = 0x0F20;             // 黒底白字空白符

    Screen::Screen(const uint8_t &x, const uint8_t &y) :
	VGA(),cursor_x(x), cursor_y(y)
    {
	move_cursor();
    }

    void Screen::set_cursor(uint8_t x, uint8_t y)
    {
	cursor_x = x;
	cursor_y = y;
    }
    
    void Screen::clear_screen()
    {
	// 本质上就是在黑底上写满空白符
   	for (uint16_t i = 0; i != 80 * 25; i++)
	    video_address[i] = blank;
	set_cursor(0, 0);
	move_cursor();
    }

    void Screen::print_string(char *str, vga_color fore, vga_color back)
    {
	while (*str)
	{
	    print_char(*str++, fore, back);
	}
    }

    
    void Screen::print_string(char *str)
    {
	print_string(str, COLOR_WHITE, COLOR_BLACK);
    }

    void Screen::move_cursor()
    {
	move_cursor(cursor_x, cursor_y);
    }

    void Screen::move_cursor(const uint8_t &x, const uint8_t &y)
    {
        // note:(x,y)坐标，不是行和列
	uint16_t cursor_pos = y * 80 + x;
	outb(0x3D4, 0x0E);
	outb(0x3D5, (cursor_pos >> 8) & 0xFF);
	outb(0x3D4, 0x0F);
	outb(0x3D5, cursor_pos & 0xFF);
    }

    void Screen::scroll_line()
    {
	if (cursor_y > 24)
	{
	    for (int i = 0 * 80; i != 24 * 80; i++) 
		video_address[i] = video_address[i + 80];
	    for (int i = 24 * 80; i != 25 * 80; i++) 
		video_address[i] = blank;
	    cursor_y = 24;
	}
	move_cursor(0, cursor_y);   // 从行首开始
    }

    void Screen::print_char(char ch)
    {
	print_char(ch, COLOR_WHITE, COLOR_BLACK);
    }

    void Screen::print_char(char ch, vga_color fore, vga_color back)
    {
	uint16_t attribute = get_attribute(fore, back);
	
	if (cursor_x >= 80)
	{
	    cursor_x = 0;
	    cursor_y++;
	}
	
	video_address[cursor_y * 80 + cursor_x] = ch | attribute;
	cursor_x++;

	move_cursor();
    }

    // fore:前景色，即字符颜色；back背景色
    uint16_t Screen::get_attribute(vga_color fore, vga_color back) const
    {
	uint8_t fore_color = (uint8_t)fore;
	uint8_t back_color = (uint8_t)back;
	uint8_t attribute_byte = (back_color << 4) | (fore_color & 0x0F);
	uint16_t attribute = attribute_byte << 8;
	
	return attribute;
    }
}
