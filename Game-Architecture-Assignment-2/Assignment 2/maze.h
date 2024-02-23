////////////////////////////////////////////////////////////////////////////
//
// Maze - maze object
//	Generates and accesses a 2D maze.
//  Represents the maze as a 2D array of cells.
//  Each cell contains flags to indicate which walls exist.
//  The algorithm for the maze construction uses disjoint sets.
//
// (c) 2010-2015 Borna Noureddin
//      British Columbia Institute of Technology
//      School of Computing and Academic Studies
//
////////////////////////////////////////////////////////////////////////////



#ifndef __MAZE_H__
#define __MAZE_H__

#include "DisjointSet.h"

struct MazeCell
{
	bool northWallPresent, southWallPresent, eastWallPresent, westWallPresent;
};

typedef enum { dirNORTH=0, dirEAST, dirSOUTH, dirWEST } Direction;

class Maze
{

	public:
		int rows, cols;						// size of maze
		Maze(int rows = 4, int cols = 4);	// default size is 4x4 maze
		~Maze();
		MazeCell GetCell(int r, int c);

		void Create();	// creates a random maze

	private:
		DisjointSet *mazeSet;
		MazeCell **maze;

};

#endif
