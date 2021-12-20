-- stub out the kong functions
_G.kong = {}
_G.kong.request = {}
_G.kong.service = {}
_G.kong.service.request = {}
_G.kong.service.request.set_path = function(arg) end



-- Test suite
describe("Kong Path Transformation", function()

  -- Test 1
  it("should change path /foo/1 into /1", function()

   -- this lets us check the result after running our script
   spy.on(_G.kong.service.request, "set_path")

   -- stub out kong.request.get_path() to return "/foo/1" when run locally
   _G.kong.request.get_path = function(arg) return "/foo/1" end

   -- run our plugin script
   dofile("../src/mediate.lua")

   -- check that the result is what we expect
   assert.spy(_G.kong.service.request.set_path).was_called_with("/1") 
  end)

  -- Test 2

  it("shouldn't change path /1", function()
   
   -- this lets us check the result after running our script
   spy.on(_G.kong.service.request, "set_path")

   -- stub out kong.request.get_path() to return "/1" when run locally
   _G.kong.request.get_path = function(arg) return "/1" end

   -- run our plugin script
   dofile("../src/mediate.lua")

   -- check that the result is what we expect
   assert.spy(_G.kong.service.request.set_path).was_called_with("/1") 
  end)

end)
