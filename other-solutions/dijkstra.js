/**
 * Dijkstra implementation from: noam-sauer-utley
 *  https://levelup.gitconnected.com/finding-the-shortest-path-in-javascript-dijkstras-algorithm-8d16451eea34
 */
const findShortestPath = ( graph, startNode, endNode ) => {
    // track distances from the start node using a hash object
    let distances = {};
    distances[ endNode ] = "Infinity";
    distances = Object.assign( distances, graph[ startNode ] );

    // track paths using a hash object
    let parents = { endNode: null };
    for( let child in graph[ startNode ] ){
        parents[ child ] = startNode;
    }

    // collect visited nodes
    let visited = [];
    // find the nearest node
    let node = shortestDistanceNode( distances, visited );

    // for that node:
    while( node ){
        // find its distance from the start node & its child nodes
        let distance = distances[ node ];
        let children = graph[ node ];

        // for each of those child nodes:
        for( let child in children ){
            // make sure each child node is not the start node
            if( String( child ) === String( startNode ) ){
                continue;
            } else {
                // save the distance from the start node to the child node
                let newDist = distance + children[ child ];
                // if there's no recorded distance from the start node to the child node in the distances object
                // or if the recorded distance is shorter than the previously stored distance from the start node to the child node
                if( !distances[ child ] || distances[ child ] > newDist ){
                    // save the distance to the object
                    distances[ child ] = newDist;
                    // record the path
                    parents[ child ] = node;
                }
            }
        }
        // move the current node to the visited set
        visited.push( node );
        // move to the nearest neighbor node
        node = shortestDistanceNode( distances, visited );
        console.log( 'entered ', node )
    }

    // After processing all nodes
    // using the stored paths from start node to end node
    // record the shortest path
    let shortestPath = [ endNode ];
    let parent = parents[ endNode ];
    while( parent ){
        shortestPath.push( parent );
        parent = parents[ parent ];
    }
    shortestPath.reverse();

    // return the shortest path & the end node's distance from the start node
    let results = {
        distance: distances[ endNode ],
        path: shortestPath,
    };
    return results;
};

const shortestDistanceNode = ( distances, visited ) => {
    let shortest = null;

    // for each node in the distances object
    for( let node in distances ){
        // if node hasn't been visited yet
        // Check if first node in iteration (no shortest assigned yet), or distance is smaller than current shortest
        if( !visited.includes( node ) && ( shortest === null || distances[ node ] < distances[ shortest ] ) ){
            // update shortest to be the current node
            shortest = node;
        }
    }
    return shortest;
};

module.exports = { findShortestPath };