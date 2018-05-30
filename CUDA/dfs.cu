#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <queue>
#include <sstream>
#include <cuda_runtime.h>
#define NODES 67108863            //Only 2 exp(n)-1 values

//This Works Only On Cpmplete Binary Tree
//You Can Use a Non-Complete Tree if you complete nodes with NULL

using namespace std;

typedef struct node{
    bool visited;
    int n;
    struct node *left;
    struct node *right;
    struct node *parent;
}node;

__constant__ node *tree;

void toArray(node **tree, int nodes){
    *tree = (node*)malloc(nodes * sizeof(**tree));
}

//On Huge Trees:: can be paralelized
__global__ void makeEdges(int length){
    int limit = (length/2) - 1;
    int x = threadIdx.x;
    //printf("Value on limit index: %d \n", tree[limit].n);
    //for(int x = 0; x <= limit; x++){
    if(x < limit){
        tree[x].left = &tree[(2 * x) + 1];
        tree[x].right = &tree[(2 * x) + 2];
    }
    /*for(int y = (limit + 1); y < NODES; y++){
        tree[y].left = NULL;
        tree[y].right = NULL;
    }*/
}

//On Huge Trees:: can be paralelized
__global__ void findParents(int nodes){
    int x = threadIdx.x;
    if(x < nodes){
        if(x == 0){
            tree[x].parent = NULL;
        }else{
            int par = (x - 1)/2;
            tree[x].parent = &tree[par];
        }
    }
}

//On Huge Trees:: can be paralelized
__global__ void makeTree(int nodes){
    int x = threadIdx.x;
    if(x < nodes){
        tree[x].n = x + 1;
        tree[x].visited = false;
    }
}

bool hasChildren(node n){
    if(n.left != NULL && n.right != NULL){
        return true;
    }else{
        return false;
    }
}

//The Interesting Part!!
void DFS(int element, node* tree){
    bool found = false;
    queue <int> path;
    node *temp = &tree[0];

	do{
	    //printf("On node with element %d \n", temp->n);
	    if(temp->n != element){
	    	path.push(temp->n);
	        if (hasChildren(*temp)){
	            if(temp->left->visited == false){
	                temp = temp->left;
	            }else if(temp->right->visited == false){
					temp = temp->right;
				}else{
					temp->visited = true;
					temp = temp->parent;
				}
	        }else{
	            temp->visited = true;
	            temp = temp->parent;
	        }
	    }else{
	        found = true;
	        path.push(temp->n);
	        printf("Element Found!: %d \n", temp->n);
	    }
	}while(found == false);
/*    while(!path.empty()){
		printf(" %d ", path.front());
		path.pop();
	}
*/
	printf("\n");
}

int main(int argc, char **argv){
	int to_find = 0;
	stringstream ss;
    //Creation of Tree Array
    toArray(&tree, NODES);
    cudaMalloc((node**)&tree, (NODES*sizeof(node)));
    //makeTree(NODES);
    makeTree<<<1,1>>>(NODES);
    //cudaMemcpy(&tree, d_tree, cudaMemcpyDeviceToHost);
    //END
    /*for(int i; i < NODES; i++){
        printf("Node %d element: %d \n", i, tree[i].n);
    }*/
    //printf("Levels %d \n", lvlNumber(NODES));
    //printf("Last Level Nodes %d \n", lastLvlNodes(lvlNumber(NODES)));
    //makeEdges(NODES);
    makeEdges<<<1,1>>>(NODES);
    //cudaMemcpy(d_tree, &tree, cudaMemcpyHostToDevice);
    //findParents();
    findParents<<<1,1>>>(NODES);
    //printf("Right value from 2 node's child: %d \n", tree[2].right->n);
    //printf("Left value from 2 node's child: %d \n", tree[2].left->n);
    //printf("Parent of node 14 element: %d \n", tree[14].parent->n);
    //printf("Has the node 14 children?: %d \n", hasChildren(tree[14]));
    cudaMemcpy(&ar, &tree, (NODES*sizeof(*tree)),cudaMemcpyDeviceToHost);

    ss << argv[1];
    ss >> to_find;
    DFS(to_find);
    cudaFree(tree);
    return(0);
}
