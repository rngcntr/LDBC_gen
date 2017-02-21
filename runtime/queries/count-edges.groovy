DATASET = System.env.get("DATASET");

graph = TinkerGraph.open()

stime = System.nanoTime()
graph.io(IoCore.gryo()).readGraph(DATASET_FILE)
exec_time = System.currentTimeMillis() - stime

result_row = [DATASET, 'load',String.valueOf(exec_time),'']
println result_row.join(',')

g = graph.traversal()

stime = System.nanoTime()
count = g.E.count().next()
exec_time = System.nanoTime() - stime

result_row = [DATASET,"count-edges", String.valueOf(exec_time), String.valueOf(count)]
println result_row.join(',')



