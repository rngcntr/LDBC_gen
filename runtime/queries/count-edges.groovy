DATASET = System.env.get("DATASET");

graph = TinkerGraph.open()

if(DATASET.endsWith('.json')) {
    reader = IoCore.graphson()
} else if (DATASET.endsWith('.kryo')) {
    reader = IoCore.gryo()
} else {
    System.err.println("File extension of "  + DATASET +  " not recognizes." );
    System.exit(2)
}



stime = System.nanoTime()
graph.io(reader).readGraph(DATASET)
exec_time = System.currentTimeMillis() - stime

result_row = [DATASET, 'load',String.valueOf(exec_time),'']
println result_row.join(',')

g = graph.traversal()

stime = System.nanoTime()
count = g.E.count().next()
exec_time = System.nanoTime() - stime

result_row = [DATASET,"count-edges", String.valueOf(exec_time), String.valueOf(count)]
println result_row.join(',')



