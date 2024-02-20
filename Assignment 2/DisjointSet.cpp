////////////////////////////////////////////////////////////////////////////
//
// DisjointSet - simple disjoint set class
//  Does searches and unions, and no error checking.
//
// (c) 2010-2015 Borna Noureddin
//      British Columbia Institute of Technology
//      School of Computing and Academic Studies
//
////////////////////////////////////////////////////////////////////////////



//#include "stdafx.h"
#include "DisjointSet.h"

DisjointSet::DisjointSet(int setSize)
{
	setArray = new int[setSize];
    for(int i = 0; i < setSize; i++)
		setArray[i] = -1;
}

DisjointSet::~DisjointSet()
{
	delete [] setArray;
}

void DisjointSet::UnionSets(int s1, int s2)
{
	if(s1<s2)
		setArray[s2]=s1;
	else
		setArray[s1]=s2;
}

int DisjointSet::Find(int x)
{
	if (setArray[x] < 0)
		return x;
	else
		return Find(setArray[x]);
}
