return {}
-- local ls = require("luasnip")
-- -- some shorthands...
-- local s = ls.snippet
-- local t = ls.text_node
-- local i = ls.insert_node
--
-- ls.add_snippets("py", {
--   -- Use a dynamicNode to interpolate the output of a
--   -- function (see date_input above) into the initial
--   -- value of an insertNode.
--   s({
--     trig = "copyright public pal",
--     name = "pal public copyright",
--     desc = "pal public copyright snippet for python files",
--   }, {
--     t({ "# Copyright (c) ", "", " PAL Robotics S.L. All rights reserved." }, i(1, os.date("%Y"))),
--     t({ "#" }),
--     t({ '# Licensed under the Apache License, Version 2.0 (the "License");' }),
--     t({ "# you may not use this file except in compliance with the License." }),
--     t({ "# You may obtain a copy of the License at" }),
--     t({ "#" }),
--     t({ "#     http://www.apache.org/licenses/LICENSE-2.0" }),
--     t({ "#" }),
--     t({ "# Unless required by applicable law or agreed to in writing, software" }),
--     t({ '# distributed under the License is distributed on an "AS IS" BASIS,' }),
--     t({ "# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied." }),
--     t({ "# See the License for the specific language governing permissions and" }),
--     t({ "# limitations under the License." }),
--   }),
--
--   s("trig", {
--     i(1),
--     t("text"),
--     i(2),
--     t("text again"),
--     i(3),
--   }),
-- })
-- return {
--   "L3MON4D3/LuaSnip",
--   opts = {
--     config = function(_, opts)
--       require("lua.plugins.snippet.config")
--     end,
--   },
-- }
