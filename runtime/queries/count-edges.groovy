DATASET = System.env.get("DATASET");
System.err.println("Loading:  " +DATASET)

graph = TinkerGraph.open()

is = new FileInputStream(DATASET)
extension = ''
stime = System.nanoTime()
if(DATASET.endsWith('.json')) {
    extension = 'GraphSON'
    mapper = graph.io(IoCore.graphson()).mapper().typeInfo(TypeInfo.PARTIAL_TYPES).create()
    graph.io(IoCore.graphson()).reader().mapper(mapper).create().readGraph(is, graph)
} else if (DATASET.endsWith('.kryo')) {
    extension = 'Kryo'
    graph.io(IoCore.gryo()).reader().create().readGraph(is, graph)
} else {
    System.err.println("File extension of "  + DATASET +  " not recognizes." );
    System.exit(2)
}
exec_time = System.nanoTime() - stime

result_row = [DATASET, 'load',String.valueOf(exec_time),extension]
println result_row.join(',')

g = graph.traversal()

stime = System.nanoTime()
count = g.E.count().next()
exec_time = System.nanoTime() - stime

result_row = [DATASET,"count-edges", String.valueOf(exec_time), String.valueOf(count)]
println result_row.join(',')



