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



//#include "stdafx.h"
#include <stdlib.h>
#include <time.h>
#include "maze.h"

Maze::Maze(int rows, int cols)
{
	// Set the size and create the disjoint sets and maze data structures
	this->rows = rows;
	this->cols = cols;
	mazeSet = new DisjointSet(rows * cols);
	maze = (MazeCell **)calloc(rows, sizeof(MazeCell *));
	for (int i=0; i<rows; i++) {
		maze[i] = (MazeCell *)calloc(cols, sizeof(MazeCell));
		for(int j=0; j<cols; j++) {
			// by default, all the walls exist
			maze[i][j].northWallPresent = true;
			maze[i][j].southWallPresent = true;
			maze[i][j].eastWallPresent = true;
			maze[i][j].westWallPresent = true;
		}
	}
}

Maze::~Maze()
{
//	delete mazeSet;
//	for (int i=0; i<rows; i++)
//		free(maze[i]);
//	free(maze);
}

void Maze::Create()
{
    maze[0][0].northWallPresent = false;            // entrance
    maze[rows-1][cols-1].southWallPresent = false;    // exit
    srand((unsigned int)time(NULL));
    int entrySet = mazeSet->Find(0);
    int exitSet = mazeSet->Find(((rows*cols)-1));

    
    while (entrySet != exitSet) {

        // Pick a random wall to knock down
        int randRow = rand() % rows;
        int randCol = rand() % cols;
        int wall = rand() % 4;
        int s1 = 0, s2 = 0;

        switch (wall) {
        case dirNORTH:
            if (randRow > 0) { // not top of maze
                s1 = mazeSet->Find(cols * randRow + randCol);
                s2 = mazeSet->Find(cols * (randRow-1) + randCol);
                if (s1 != s2) {
                    maze[randRow][randCol].northWallPresent = false;
                    maze[randRow-1][randCol].southWallPresent = false;
                    mazeSet->UnionSets(s1, s2);
                }
            }
            break;

        case dirSOUTH:
            if (randRow < (rows-1)) { // not bottom of maze
                s1 = mazeSet->Find(cols * randRow + randCol);
                s2 = mazeSet->Find(cols * (randRow+1) + randCol);
                if (s1 != s2) {
                    maze[randRow][randCol].southWallPresent = false;
                    maze[randRow+1][randCol].northWallPresent = false;
                    mazeSet->UnionSets(s1, s2);
                }

            }
            break;

        case dirEAST:
            if (randCol < (cols-1)) { // not right of maze
                s1 = mazeSet->Find(cols * randRow + randCol);
                s2 = mazeSet->Find(cols * randRow + randCol+1);
                if (s1 != s2) {
                    maze[randRow][randCol].eastWallPresent = false;
                    maze[randRow][randCol+1].westWallPresent = false;
                    mazeSet->UnionSets(s1, s2);
                }

            }
            break;

        case dirWEST:
            if (randCol > 0) { // not left of maze
                s1 = mazeSet->Find(cols * randRow + randCol);
                s2 = mazeSet->Find(cols * randRow + randCol-1);
                if (s1 != s2) {
                    maze[randRow][randCol].westWallPresent = false;
                    maze[randRow][randCol-1].eastWallPresent = false;
                    mazeSet->UnionSets(s1, s2);
                }

            }
            break;
        }

        entrySet = mazeSet->Find(0);
        exitSet = mazeSet->Find(((rows*cols)-1));

    }

}

void Maze::CreateWithSeed(int seed)
{
	maze[0][0].northWallPresent = false;			// entrance
	maze[rows-1][cols-1].southWallPresent = false;	// exit
	//srand((unsigned int)time(NULL));
    srand(seed);
	int entrySet = mazeSet->Find(0);
	int exitSet = mazeSet->Find(((rows*cols)-1));

    
	while (entrySet != exitSet) {

		// Pick a random wall to knock down
		int randRow = rand() % rows;
		int randCol = rand() % cols;
		int wall = rand() % 4;
		int s1 = 0, s2 = 0;

		switch (wall) {
		case dirNORTH:
			if (randRow > 0) { // not top of maze
				s1 = mazeSet->Find(cols * randRow + randCol);
				s2 = mazeSet->Find(cols * (randRow-1) + randCol);
				if (s1 != s2) {
					maze[randRow][randCol].northWallPresent = false;
					maze[randRow-1][randCol].southWallPresent = false;
					mazeSet->UnionSets(s1, s2);
				}
			}
			break;

		case dirSOUTH:
			if (randRow < (rows-1)) { // not bottom of maze
				s1 = mazeSet->Find(cols * randRow + randCol);
				s2 = mazeSet->Find(cols * (randRow+1) + randCol);
				if (s1 != s2) {
					maze[randRow][randCol].southWallPresent = false;
					maze[randRow+1][randCol].northWallPresent = false;
					mazeSet->UnionSets(s1, s2);
				}

			}
			break;

		case dirEAST:
			if (randCol < (cols-1)) { // not right of maze
				s1 = mazeSet->Find(cols * randRow + randCol);
				s2 = mazeSet->Find(cols * randRow + randCol+1);
				if (s1 != s2) {
					maze[randRow][randCol].eastWallPresent = false;
					maze[randRow][randCol+1].westWallPresent = false;
					mazeSet->UnionSets(s1, s2);
				}

			}
			break;

		case dirWEST:
			if (randCol > 0) { // not left of maze
				s1 = mazeSet->Find(cols * randRow + randCol);
				s2 = mazeSet->Find(cols * randRow + randCol-1);
				if (s1 != s2) {
					maze[randRow][randCol].westWallPresent = false;
					maze[randRow][randCol-1].eastWallPresent = false;
					mazeSet->UnionSets(s1, s2);
				}

			}
			break;
		}

		entrySet = mazeSet->Find(0);
		exitSet = mazeSet->Find(((rows*cols)-1));

	}

}

MazeCell Maze::GetCell(int r, int c)
{
	return maze[r][c];
}
