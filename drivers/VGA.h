/*
 * VGA虚基类，定义操作接口
 *
 */

#ifndef VGA_H
#define VGA_H


namespace IO
{
    class VGA
    {
    public:
	VGA()  = default;
	~VGA() = default;
	virtual void clear_screen() { }           // 清屏
	virtual void scroll_screen() { }          // 屏幕滚动
	virtual void print_string(char*) { }      // 显示字符串
    };
}


#endif /* VGA_H */
