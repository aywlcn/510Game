#include "BitLib.h"

/************************************************************************/
/* ������                                                               */
/************************************************************************/
int LuaBitLib::bAnd(int a, int b)
{
	return a & b;
}

/************************************************************************/
/* ������                                                               */
/************************************************************************/
int LuaBitLib::bOr(int a, int b)
{
	return a | b;
}

/************************************************************************/
/* ���������                                                            */
/************************************************************************/
int LuaBitLib::lShift(int a, int b)
{
	return a << b;
}

/************************************************************************/
/* ���������                                                            */
/************************************************************************/
int LuaBitLib::rShift(int a, int b)
{
	return a >> b;
}

/************************************************************************/
/* ȡ�������                                                            */
/************************************************************************/
int LuaBitLib::bNot(int a)
{
	return ~a;
}