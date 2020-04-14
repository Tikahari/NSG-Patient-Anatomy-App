
import numpy
def loop_access(n,m,data,tpl):
    if n >m:
        return loop_access(n,m+1,data[tpl[m]],tpl)
    else:
        print('test: ' + str(data[tpl[m]]))
        print('test: ' + str(data[tpl[m]]))
        return data[tpl[m]]

def loop_rec(n,m,mapCoords,dims,data,tple):
    if n >= m:
        for x in range(dims[m]):
            loop_rec(n,m+1,mapCoords,dims,data,(tple+(x,)))
    else:
        temp = loop_access(len(dims)-1,0,data,tple)
        print(temp)
        if temp in mapCoords:
            mapCoords[temp].append(tple)# add coord to list
        else:
            mapCoords[temp] = list() #make list, it doesn't exiss:



data = numpy.random.randint(low=1,high=20,size=(2,4,2,2,3))

for a in range(data.shape[0]):
    for b in range(data.shape[1]):
        for c in range(data.shape[2]):
            for d in range(data.shape[3]):
                for e in range(data.shape[4]):
                    print(str((a,b,c,d,e)) + ' : ' + str(data[a,b,c,d,e]))


tep = ()
mapCoords = dict()
loop_rec(len(data.shape)-1,0,mapCoords,data.shape,data,tep)
for key in mapCoords:
        tList = mapCoords[key]
        for coord in tList:
            print(str(coord) + ' : ' + str(key))


