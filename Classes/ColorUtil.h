//
//  ColorUtil.h
//  Eden
//
//  Created by Ari Ronen on 1/12/13.
//
//

#ifndef Eden_ColorUtil_h
#define Eden_ColorUtil_h




void RGBtoHSL(unsigned int color,unsigned int& h, unsigned int& s, unsigned int& l);
unsigned int HSLtoRGB(const unsigned int& h, const unsigned int& s, const unsigned int& l);
unsigned int BrightenColor(unsigned int color,unsigned int amount);
unsigned int DarkenColor(unsigned int color,unsigned int amount);
extern "C" void RGB2HSL(unsigned int color,unsigned int* h,unsigned int* s,unsigned int* l);
extern "C" unsigned int HSL2RGB(unsigned int h,unsigned int s,unsigned int l);

#endif
