print ( "hello" )

MOAISim.openWindow ( "Penyo Restaurant", 480, 320 )

VIEW_W = 480
VIEW_H = 320

MOAIDebugLines.setStyle ( MOAIDebugLines.PARTITION_CELLS, 2, 1, 1, 1 )
MOAIDebugLines.setStyle ( MOAIDebugLines.PARTITION_PADDED_CELLS, 1, 0.5, 0.5, 0.5 )
MOAIDebugLines.setStyle ( MOAIDebugLines.PROP_WORLD_BOUNDS, 2, 0.75, 0.75, 0.75 )

-- helpers
function distance ( x1, y1, x2, y2 ) 
  return math.sqrt ((( x2 - x1 ) ^ 2 ) + (( y2 - y1 ) ^ 2 ))
end

function pairsByKeys (t, f)
  local a = {}
  for n in pairs(t) do table.insert(a, n) end
  table.sort(a, f)
  local i = 0      -- iterator variable
  local iter = function ()   -- iterator function
    i = i + 1
    if a[i] == nil then return nil
    else return a[i], t[a[i]]
    end
  end
  return iter
end

--

charcodes = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 .,:;!?()&/-'
font = MOAIFont.new ()
font:loadFromTTF ( 'arialbd.ttf', charcodes, 16, 163 )

viewport = MOAIViewport.new ()
viewport:setScale ( 480, 320 )
viewport:setSize ( VIEW_W, VIEW_H )

partition = MOAIPartition.new ()
partition:reserveLevels ( 1 )
partition:setLevel ( 1, 20, 24, 16 )

partitionw = MOAIPartition.new ()
partitionw:reserveLevels ( 1 )
partitionw:setLevel ( 1, 20, 24, 16 )

layerBg = MOAILayer2D.new ()
layerBg:setViewport ( viewport )
MOAISim.pushRenderPass ( layerBg )



-- sounds

if MOAIUntzSystem then

  MOAIUntzSystem.initialize ()

  beat = MOAIUntzSound.new ()
  beat:load ( 'assets/sounds/mono16.wav' )
  beat:setVolume ( 1 )
  beat:setLooping ( true )
  beat:play ()

  ding = MOAIUntzSound.new ()
  ding:load ( 'assets/sounds/ding.aif' )
  ding:setVolume ( 0.2 )
  ding:setLooping ( false )
end


-- layers

layer = MOAILayer2D.new ()
layer:setViewport ( viewport )
layer:setPartition ( partition )
MOAISim.pushRenderPass ( layer )

layerw = MOAILayer2D.new ()
layerw:setViewport ( viewport )
layerw:setPartition ( partitionw )
MOAISim.pushRenderPass ( layerw )


--insert winning area

winGfx = MOAIGfxQuad2D.new ()
winGfx:setTexture ( "assets/images/order.png" )
winGfx:setRect ( -100, -50, 0, 50 )

win = MOAIProp2D.new ()
win:setLoc ( -20, -110 )
win:setDeck ( winGfx )

layerw:insertProp ( win )


-- insert bg

bgGfx = MOAIGfxQuad2D.new ()
bgGfx:setTexture ( "assets/images/background.png" )
bgGfx:setRect ( -VIEW_W/2, -VIEW_H/2, VIEW_W/2, VIEW_H/2 )
   
base = MOAIProp2D.new ()
base:setDeck ( bgGfx )
base:setLoc ( 0, 0 )

layerBg:insertProp ( base )


-- insert order

ORDER_W = 128
ORDER_H = 160

orderGfx = MOAIGfxQuad2D.new ()
orderGfx:setTexture ( "assets/images/order.png" )
orderGfx:setRect ( -ORDER_W/2, -ORDER_H/2, ORDER_W/2, ORDER_H/2 )

Order = {count = 0; id = 0; orders = {}}

function Order.remove (self, _id)
  self.orders[_id] = nil
  self.count = self.count - 1

  -- tell other orders to move
  local i = 0
  for id, o in pairsByKeys(self.orders) do
    i = i + 1
    --o.thread:run ( o:move(o:getLocation(i)), o )
    o:move(o:getLocation(i))
  end
end

function Order.new (self)
  if ding then 
    ding:play ()
  end

  self.count = self.count + 1
  self.id = self.id + 1

  self.orders[self.id] = MOAIProp2D.new ()
  self.orders[self.id].id = self.id
  local order = self.orders[self.id]

  local start_x = VIEW_W+ORDER_W/2
  local start_y = 70
  local end_y = start_y

  --local order = MOAIProp2D.new ()
  order:setDeck ( orderGfx )
  order:setLoc ( start_x, start_y )
  layer:insertProp ( order )

   
  order.textbox = MOAITextBox.new ()
  order.textbox:setColor(99,99,99)
  order.textbox:setFont ( font )
  order.textbox:setTextSize ( 20 )
  order.textbox:setRect ( -20, -20, 20, 20 )
  order.textbox:setYFlip ( true )
  order.textbox:setString ( "" .. self.id )
  order.textbox:setAttrLink (MOAIProp2D.ATTR_X_LOC, order, MOAIProp2D.ATTR_X_LOC)
  order.textbox:setAttrLink (MOAIProp2D.ATTR_Y_LOC, order, MOAIProp2D.ATTR_Y_LOC)
  layer:insertProp (order.textbox)



  function order:main ()
    self:move(self:getLocation(Order.count))
  end

  function order:remove ()
    Order:remove(self.id)
    layer:removeProp ( self )
    layer:removeProp ( self.textbox)
  end

  function order:move(target_x)
    if self.anim then
      self.anim:stop()
    end

    local target_y = end_y
    local speed = 100
    local travelDist = distance ( start_x, start_y, target_x, target_y )
    local travelTime = travelDist / speed
    print('d ' .. travelDist)
    print('t ' ..travelTime)
    print(self.id .. 'moving to:' .. target_x)
    
    --MOAICoroutine.blockOnAction ( self:seekLoc ( target_x, target_y, travelTime, MOAIEaseType.LINEAR ))
    self.anim = self:seekLoc ( target_x, target_y, travelTime, MOAIEaseType.EASE_IN )
  
  end

  function order:getLocation (ind)
    return -VIEW_W/2+ind*110-30
  end

  -- order.thread = MOAICoroutine.new ()
  -- order.thread:run ( order.main, order )

  order:main()
end


if ( MOAIInputMgr.device.pointer     and
     MOAIInputMgr.device.mouseLeft ) then

  mouseX = 0
  mouseY = 0
  objectX = 0
  objectY = 0
  mouseDown = false
  objectDrag = nil


  MOAIInputMgr.device.pointer:setCallback (
    function ( x, y )
      mouseX, mouseY = layer:wndToWorld ( x, y )
      
      if mouseDown then
        if objectDrag then

          objectDrag:setLoc ( mouseX-objectX, mouseY-objectY )
        end
      end
    end
  )
  
  MOAIInputMgr.device.mouseLeft:setCallback (
    function ( down )
      if down then
        mouseDown = true
        pick = partition:propForPoint ( mouseX, mouseY, 0 )
        

        if pick then
          objectDrag = pick 
          objectX, objectY = objectDrag:worldToModel (mouseX, mouseY)
        end

      else

        dropzone = partitionw:propForPoint ( mouseX, mouseY, 0 )
        if dropzone then
          if objectDrag and objectDrag.remove then
            objectDrag:remove()
          end
        end
        objectDrag = nil
        mouseDown = false

      end
    end
  )
end



mainThread = MOAICoroutine.new ()
mainThread:run (
  function ()
    local frames = 0
    Order:new ()
    while true do
      coroutine.yield ()
      frames = frames + 1
      if Order.count < 4 then 
        if frames >= 90 then
          frames = 0
          Order:new ()
        end
      end
    end
  end
)