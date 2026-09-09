-- Read Scener XML directly and tessellate its primitives for the platform host.
local Projection = require "Book.Scripts.SceneProjection"
local Scene = {}
Scene.__index = Scene
local pi = math.pi

local function vec(text, fallback)
    if not text then return fallback end
    local v = {}
    for n in text:gmatch('%S+') do v[#v + 1] = assert(tonumber(n)) end
    assert(#v == 3, 'expected three vector components')
    return v
end
local function sub(a,b) return {a[1]-b[1],a[2]-b[2],a[3]-b[3]} end
local function cross(a,b) return {a[2]*b[3]-a[3]*b[2],a[3]*b[1]-a[1]*b[3],a[1]*b[2]-a[2]*b[1]} end
local function dot(a,b) return a[1]*b[1]+a[2]*b[2]+a[3]*b[3] end
local function norm(a)
    local d=math.sqrt(dot(a,a))
    if d < 1e-12 then return {0,0,1} end
    return {a[1]/d,a[2]/d,a[3]/d}
end
local function transform(attrs, parent, offset)
    local p=vec(attrs.pos,{0,0,0})
    local r=vec(attrs.rot,{0,0,0})
    local s=vec(attrs.scale,{1,1,1})
    local cx,sx=math.cos(r[1]*pi/180),math.sin(r[1]*pi/180)
    local cy,sy=math.cos(r[2]*pi/180),math.sin(r[2]*pi/180)
    local cz,sz=math.cos(r[3]*pi/180),math.sin(r[3]*pi/180)
    return function(v)
        local x,y,z=v[1]*s[1],v[2]*s[2],v[3]*s[3]
        y,z=cx*y-sx*z,sx*y+cx*z
        x,z=cy*x+sy*z,-sy*x+cy*z
        x,y=cz*x-sz*y,sz*x+cz*y
        return parent({x+p[1]*.01+(offset and offset[1] or 0),
            y+p[2]*.01+(offset and offset[2] or 0),z+p[3]*.01+(offset and offset[3] or 0)})
    end
end
local function box(emit,x,y,z,oz)
    local p={}
    for _,v in ipairs({{-1,-1,-1},{1,-1,-1},{1,1,-1},{-1,1,-1},
        {-1,-1,1},{1,-1,1},{1,1,1},{-1,1,1}}) do
        p[#p+1]={v[1]*x/2,v[2]*y/2,v[3]*z/2+(oz or 0)}
    end
    for _,f in ipairs({{1,4,3,2},{5,6,7,8},{1,2,6,5},{4,8,7,3},{1,5,8,4},{2,3,7,6}}) do
        emit(p[f[1]],p[f[2]],p[f[3]]);emit(p[f[1]],p[f[3]],p[f[4]])
    end
end
local function cylinder(emit,r,rt,h,n)
    for i=0,n-1 do
        local a,b=i*2*pi/n,(i+1)*2*pi/n
        local p={r*math.cos(a),-h/2,r*math.sin(a)}
        local q={r*math.cos(b),-h/2,r*math.sin(b)}
        local u={rt*math.cos(a),h/2,rt*math.sin(a)}
        local v={rt*math.cos(b),h/2,rt*math.sin(b)}
        emit(p,u,v);emit(p,v,q)
        emit({0,-h/2,0},p,q);emit({0,h/2,0},v,u)
    end
end
local function surface(emit,nu,nv,point)
    for u=0,nu-1 do for v=0,nv-1 do
        local a,b,c,d=point(u/nu,v/nv),point((u+1)/nu,v/nv),
            point((u+1)/nu,(v+1)/nv),point(u/nu,(v+1)/nv)
        emit(a,b,c);emit(a,c,d)
    end end
end

local function extrude(emit, points, depth)
    local function at(p,z) return {p[1],p[2],z} end
    for i=2,#points-1 do
        emit(at(points[1],depth/2),at(points[i],depth/2),at(points[i+1],depth/2))
        emit(at(points[1],-depth/2),at(points[i+1],-depth/2),at(points[i],-depth/2))
    end
    for i=1,#points do
        local p,q=points[i],points[i%#points+1]
        emit(at(p,-depth/2),at(q,-depth/2),at(q,depth/2))
        emit(at(p,-depth/2),at(q,depth/2),at(p,depth/2))
    end
end
local function inverse(t)
    local p=t({0,0,0})
    local x,y,z=sub(t({1,0,0}),p),sub(t({0,1,0}),p),sub(t({0,0,1}),p)
    local det=dot(x,cross(y,z))
    assert(math.abs(det)>1e-12,'singular scene transform')
    local a,b,c=cross(y,z),cross(z,x),cross(x,y)
    return function(v) local d=sub(v,p);return {dot(a,d)/det,dot(b,d)/det,dot(c,d)/det} end
end
local function arch(emit,w,h,d,tube,n)
    local r,spring=w/2,h/2-w/2
    if tube<=0 or tube>=r then
        local points={{-r,-h/2},{r,-h/2}}
        for i=0,n do local a=pi*i/n;points[#points+1]={r*math.cos(a),spring+r*math.sin(a)} end
        extrude(emit,points,d)
        return
    end
    local inner=r-tube
    extrude(emit,{{-r,-h/2},{r,-h/2},{r,-h/2+tube},{-r,-h/2+tube}},d)
    extrude(emit,{{-r,-h/2+tube},{-inner,-h/2+tube},{-inner,spring},{-r,spring}},d)
    extrude(emit,{{inner,-h/2+tube},{r,-h/2+tube},{r,spring},{inner,spring}},d)
    for i=0,n-1 do
        local a,b=pi*i/n,pi*(i+1)/n
        extrude(emit,{{inner*math.cos(a),spring+inner*math.sin(a)},
            {r*math.cos(a),spring+r*math.sin(a)},
            {r*math.cos(b),spring+r*math.sin(b)},
            {inner*math.cos(b),spring+inner*math.sin(b)}},d)
    end
end
local function wall(emit,t,length,height,depth,negatives)
    local inv=inverse(t)
    local cuts={-length/2,length/2}
    local openings={}
    for _,negative in ipairs(negatives) do
        local c=inv(negative.t({0,0,0}))
        local x=sub(inv(negative.t({1,0,0})),c)
        local y=sub(inv(negative.t({0,1,0})),c)
        local z=sub(inv(negative.t({0,0,1})),c)
        if math.abs(norm(x)[1])>.999 and math.abs(norm(y)[2])>.999 and math.abs(norm(z)[3])>.999 then
            local r=negative.width*math.abs(x[1])/2
            local h=negative.height*math.abs(y[2])
            local d=negative.depth*math.abs(z[3])
            if c[3]-d/2<=-depth/2+.001 and c[3]+d/2>=depth/2-.001 and c[1]+r>-length/2 and c[1]-r<length/2 then
                local o={x=c[1],r=r,bottom=math.max(0,c[2]-h/2),spring=c[2]+h/2-r}
                openings[#openings+1]=o
                for i=0,negative.segments do
                    local px=c[1]-r*math.cos(pi*i/negative.segments)
                    if px>-length/2 and px<length/2 then cuts[#cuts+1]=px end
                end
            end
        end
    end
    table.sort(cuts)
    for i=1,#cuts-1 do
        local l,r=cuts[i],cuts[i+1]
        if r-l>1e-8 then
            local opening
            for _,o in ipairs(openings) do
                if (l+r)/2>o.x-o.r and (l+r)/2<o.x+o.r then
                    assert(not opening,'overlapping wall openings are unsupported');opening=o
                end
            end
            if opening then
                local o=opening
                local function top(x) return math.min(height,o.spring+math.sqrt(math.max(0,o.r*o.r-(x-o.x)^2))) end
                if o.bottom>0 then extrude(emit,{{l,0},{r,0},{r,o.bottom},{l,o.bottom}},depth) end
                extrude(emit,{{l,top(l)},{r,top(r)},{r,height},{l,height}},depth)
            else extrude(emit,{{l,0},{r,0},{r,height},{l,height}},depth) end
        end
    end
end

function Scene.load(path)
    local self=setmetatable({path=path,metadata=assert(Projection.load(path)),primitive_count=0,
        materials={},chunks={},vertex_count=0,prefab_count=0,bounds={min={math.huge,math.huge,math.huge},max={-math.huge,-math.huge,-math.huge}}},Scene)
    local root=assert(path:match('^(.*)/[^/]+$'))
    local cache,active,negatives={},{},{}
    local collecting=true
    local function read_prefab(source)
        if cache[source] then return cache[source] end
        assert(not source:find('..',1,true) and source:sub(1,1)~='/', 'invalid prefab path')
        local f=assert(io.open(root..'/prefabs/'..source..'.blk','r'))
        local xml=f:read('*a');f:close()
        xml=xml:gsub('<prefab%s*>','<scene>',1):gsub('</prefab>%s*$','</scene>')
        local parsed=assert(Projection.parse(xml))
        cache[source]=parsed.root
        return parsed.root
    end
    for _,n in ipairs(self.metadata.root.children) do
        if n.tag=='material' then self.materials[n.attrs.id]=vec(n.attrs.color,{.6,.6,.6}) end
    end
    self.background=vec(self.metadata.root.attrs.background,{.08,.12,.18})
    self.lighting={background=self.background,ambient=vec(self.metadata.root.attrs.ambient,{.25,.25,.25}),lights={}}
    local visit
    visit=function(node,parent)
        local a,tag=node.attrs,node.tag
        local t=transform(a,parent)
        if tag=='prefab' and a.source then
            assert(not active[a.source], 'recursive prefab: '..a.source)
            active[a.source]=true
            if not collecting then self.prefab_count=self.prefab_count+1 end
            visit(read_prefab(a.source),t)
            active[a.source]=nil
            return
        end
        if tag=='array' then
            local translation=vec(a.translation,{0,0,0})
            for i=0,(tonumber(a.count) or 1)-1 do
                local repeated=transform({},t,{translation[1]*i*.01,translation[2]*i*.01,translation[3]*i*.01})
                for _,child in ipairs(node.children) do visit(child,repeated) end
            end
            return
        end
        if tag=='bool-negative-arch' then
            if collecting then negatives[#negatives+1]={t=t,width=assert(tonumber(a.width))*.01,
                height=assert(tonumber(a.height))*.01,depth=assert(tonumber(a.depth))*.01,segments=tonumber(a.segments) or 16} end
            return
        end
        if collecting then
            for _,child in ipairs(node.children) do visit(child,t) end
            return
        end
        if tag=='light' then
            local p=t({0,0,0})
            local c=vec(a.color,{1,1,1})
            self.lighting.lights[#self.lighting.lights+1]={p[1],p[2],p[3],c[1],c[2],c[3],
                (tonumber(a.radius) or 500)*.01,tonumber(a.intensity) or 1}
            return
        end
        local color=self.materials[a.material] or {.65,.55,.4}
        local function emit(p,q,r)
            p,q,r=t(p),t(q),t(r)
            local n=norm(cross(sub(q,p),sub(r,p)))
            for _,v in ipairs({p,q,r}) do
                for axis=1,3 do
                    self.bounds.min[axis]=math.min(self.bounds.min[axis],v[axis])
                    self.bounds.max[axis]=math.max(self.bounds.max[axis],v[axis])
                end
                self.chunks[#self.chunks+1]=string.pack('=fffffffff',v[1],v[2],v[3],n[1],n[2],n[3],color[1],color[2],color[3])
            end
            self.vertex_count=self.vertex_count+3
        end
        local function cm(key,default) return (tonumber(a[key]) or default or 0)*.01 end
        local supported=true
        if tag=='box' then
            local s=vec(a.size,{1,1,1});box(emit,s[1]*.01,s[2]*.01,s[3]*.01)
        elseif tag=='wall' then wall(emit,t,cm('length'),cm('height'),cm('thickness'),negatives)
        elseif tag=='cylinder' or tag=='cone' or tag=='prism' then
            local r=cm('radius');cylinder(emit,r,tag=='cone' and cm('radiusTop') or r,cm('height'),tonumber(a.sides) or 16)
        elseif tag=='sphere' then
            local r=cm('radius')
            surface(emit,tonumber(a.slices) or 16,tonumber(a.rings) or 12,function(u,v)
                local az,el=2*pi*u,pi*v
                return {r*math.sin(el)*math.cos(az),r*math.cos(el),r*math.sin(el)*math.sin(az)}
            end)
        elseif tag=='torus' then
            local r,s=cm('majorRadius'),cm('minorRadius')
            surface(function(p,q,r) emit(p,r,q) end,tonumber(a.majorSegments) or 24,tonumber(a.minorSegments) or 8,function(u,v)
                local az,el=2*pi*u,2*pi*v
                return {(r+s*math.cos(el))*math.cos(az),s*math.sin(el),(r+s*math.cos(el))*math.sin(az)}
            end)
        elseif tag=='arch' then
            arch(emit,cm('width'),cm('height'),cm('depth'),cm('tube',tonumber(a.thickness)),tonumber(a.segments) or 16)
        else
            assert(tag=='scene' or tag=='prefab' or tag=='group' or tag=='material' or tag=='camera'
                or tag=='light' or tag=='attach','unsupported scene element: '..tag)
            supported=false
        end
        if supported then self.primitive_count=self.primitive_count+1 end
        for _,child in ipairs(node.children) do visit(child,t) end
    end
    visit(self.metadata.root,function(v)return v end)
    collecting=false
    visit(self.metadata.root,function(v)return v end)
    self.packed=table.concat(self.chunks);self.chunks=nil
    return self
end

function Scene:mesh() return self.packed end
function Scene:matrix(name,aspect)
    local c=assert(self.metadata.cameras[name], 'missing camera: '..tostring(name))
    local f=norm(sub(c.look,c.pos))
    local r=norm(cross(f,c.up=='z' and {0,0,1} or {0,1,0}))
    local u=cross(r,f)
    local v={r[1],u[1],-f[1],0,r[2],u[2],-f[2],0,r[3],u[3],-f[3],0,-dot(r,c.pos),-dot(u,c.pos),dot(f,c.pos),1}
    local near,far=.03,100
    local focal=1/math.tan(c.fov*pi/360)
    local p={focal/aspect,0,0,0,0,focal,0,0,0,0,(far+near)/(near-far),-1,0,0,2*far*near/(near-far),0}
    local m={}
    for col=0,3 do for row=0,3 do
        local x=0
        for k=0,3 do x=x+p[k*4+row+1]*v[col*4+k+1] end
        m[col*4+row+1]=x
    end end
    return m
end
return Scene
