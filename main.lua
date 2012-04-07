-- consts

WINDOW_W = 480
WINDOW_H = 320

VIEW_W = 480
VIEW_H = 320

-- debug

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

-- window, viewport

MOAISim.openWindow ( "Penyo Restaurant", WINDOW_W, WINDOW_H )

viewport = MOAIViewport.new ()
viewport:setScale ( WINDOW_W, WINDOW_H )
viewport:setSize ( VIEW_W, VIEW_H )

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

-- fonts

charcodes = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 .,:;!?()&/-'
font = MOAIFont.new ()
font:loadFromTTF ( 'arialbd.ttf', charcodes, 16, 163 )

-- partitions and layers

-- layer: background

layerBg = MOAILayer2D.new ()
layerBg:setViewport ( viewport )
MOAISim.pushRenderPass ( layerBg )

-- content: background

bgGfx = MOAIGfxQuad2D.new ()
bgGfx:setTexture ( "assets/images/background.png" )
bgGfx:setRect ( -VIEW_W/2, -VIEW_H/2, VIEW_W/2, VIEW_H/2 )
   
base = MOAIProp2D.new ()
base:setDeck ( bgGfx )
base:setLoc ( 0, 0 )

layerBg:insertProp ( base )

-- partition: orders

partition = MOAIPartition.new ()
partition:reserveLevels ( 1 )
partition:setLevel ( 1, 20, 24, 16 )

-- partition: drop zones

partitionw = MOAIPartition.new ()
partitionw:reserveLevels ( 1 )
partitionw:setLevel ( 1, 20, 24, 16 )

-- layer: drop zones

layerw = MOAILayer2D.new ()
layerw:setViewport ( viewport )
layerw:setPartition ( partitionw )
MOAISim.pushRenderPass ( layerw )

-- content: drop zones

winGfx = MOAIGfxQuad2D.new ()
winGfx:setTexture ( "assets/images/order.png" )
winGfx:setRect ( -100, -50, 0, 50 )

win = MOAIProp2D.new ()
win:setLoc ( -20, -110 )
win:setDeck ( winGfx )

layerw:insertProp ( win )

-- partition: Help locate

partitionh = MOAIPartition.new ()
partitionh:reserveLevels ( 1 )
partitionh:setLevel ( 1, 20, 24, 16 )

-- layer: Help

layerh = MOAILayer2D.new ()
layerh:setViewport ( viewport )
layerh:setPartition ( partitionh )
MOAISim.pushRenderPass ( layerh )

-- content: Help

helpGfx = MOAIGfxQuad2D.new ()
helpGfx:setTexture ( "assets/images/dot.png" )
helpGfx:setRect ( -100, -25, 25, 75 )

help = MOAIProp2D.new ()
help:setLoc ( -120, -70 )
help:setDeck ( helpGfx )

layerh:insertProp ( help )





-- layer: orders

layer = MOAILayer2D.new ()
layer:setViewport ( viewport )
layer:setPartition ( partition )
MOAISim.pushRenderPass ( layer )

-- layer: order content 

orderContentLayer = MOAILayer2D.new ()
orderContentLayer:setViewport ( viewport )
MOAISim.pushRenderPass ( orderContentLayer )

-- content: orders and order content

require ('order')

-- interaction

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
          if objectDrag.anim then
            objectDrag.anim:stop()
          end
          objectX, objectY = objectDrag:worldToModel (mouseX, mouseY)
        end

              helpneeded = partitionh:propForPoint ( mouseX, mouseY, 0 )
              
              if helpneeded then
                
                    helpGfx = MOAIGfxQuad2D.new ()
                    helpGfx:setTexture ( "assets/images/dot.png" )
                    helpGfx:setRect ( 200, -200, -200, 200 )

                    help = MOAIProp2D.new ()
                    help:setLoc ( 0, 0 )
                    help:setDeck ( helpGfx )

                    layerh:insertProp ( help )
                    
                    
                  help:setPriority(1000)
                    

              end

      else
        mouseDown = false
        dropzone = partitionw:propForPoint ( mouseX, mouseY, 0 )
        if dropzone then
          if objectDrag and objectDrag.remove then
            objectDrag:remove()
          end
        else
          if objectDrag and objectDrag.gotoTarget then
            objectDrag:gotoTarget(1000)
          end
        end
        objectDrag = nil
      
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