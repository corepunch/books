local root=assert(arg[1], 'pass absolute Book root')
package.preload['Book.Scripts.SceneProjection']=assert(loadfile(root..'/Scripts/SceneProjection.lua'))
local Projection=require 'Book.Scripts.SceneProjection'
local Scene=dofile(root..'/Standalone/scene.lua')
local scene=Scene.load(root..'/Rooms/workshop-new.blks')
assert(scene.primitive_count>500 and scene.prefab_count>20)
assert(#scene.lighting.lights==4)
assert(math.abs(scene.lighting.lights[1][3]-3.22)<1e-9)
assert(math.abs(scene.lighting.lights[1][7]-4.3)<1e-9)
assert(#scene:mesh()==scene.vertex_count*36)
local matrix=scene:matrix('workshop-floor',4/3)
for name in pairs(scene.metadata.objects) do
    local point=Projection.anchor(scene.metadata,name)
    local screen=Projection.project(scene.metadata.cameras['workshop-floor'],point,1920,1440,1920,1440)
    if screen then
        local clip={}
        for row=1,4 do
            clip[row]=matrix[row]*point[1]+matrix[row+4]*point[2]+matrix[row+8]*point[3]+matrix[row+12]
        end
        assert(math.abs((clip[1]/clip[4]+1)/2-screen.x/1920)<1e-9)
        assert(math.abs((1-clip[2]/clip[4])/2-screen.y/1440)<1e-9)
    end
end
local mesh=scene:mesh()
for offset=1,#mesh,36 do
    local x,y,z,nx,ny,nz,r,g,b=string.unpack('=fffffffff',mesh,offset)
    for _,v in ipairs({x,y,z,nx,ny,nz,r,g,b}) do assert(v==v and math.abs(v)<math.huge) end
    assert(math.abs(nx*nx+ny*ny+nz*nz-1)<1e-5)
end
local temp=os.tmpname()
local function fixture(xml)
    local file=assert(io.open(temp,'w'));file:write(xml);file:close()
    return Scene.load(temp)
end
local success,err=pcall(function()
    local f=fixture('<scene><group pos="100 0 0" rot="0 0 90"><array count="2" translation="100 0 0"><box size="100 100 100"/></array></group></scene>')
    assert(f.primitive_count==2)
    assert(math.abs(f.bounds.min[1]-.5)<1e-9 and math.abs(f.bounds.max[2]-1.5)<1e-9)
    local ok,message=pcall(fixture,'<scene><unsupported-shape/></scene>')
    assert(not ok and tostring(message):find('unsupported scene element',1,true))
    f=fixture('<scene><wall length="400" height="300" thickness="20"/><bool-negative-arch pos="0 150 0" width="100" height="200" depth="40"/></scene>')
    -- No wall face may fill the center of the arched opening.
    local data=f:mesh()
    for offset=1,#data,108 do
        local cx,cy,cz=0,0,0
        for vertex=0,2 do
            local x,y,z=string.unpack('=fff',data,offset+vertex*36)
            cx,cy,cz=cx+x/3,cy+y/3,cz+z/3
        end
        assert(not (math.abs(cx)<.45 and cy>.55 and cy<1.9 and math.abs(cz)>.099))
    end
end)
os.remove(temp)
assert(success,err)
print('Book live scene: primitives, transforms, openings, normals and camera projection passed')
