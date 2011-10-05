-module(yaml_node_bool_ext).

-include("yaml_tokens.hrl").
-include("yaml_nodes.hrl").
-include("internal/yaml_constr.hrl").

%% Public API.
-export([
    tags/0,
    try_construct_token/3,
    construct_token/3,
    node_pres/1
  ]).

-define(TAG, "tag:yaml.org,2002:bool").

-define(IS_TRUE(S),
  S == "true" orelse S == "True" orelse S == "TRUE" orelse
  S == "y" orelse S == "Y" orelse
  S == "yes" orelse S == "Yes" orelse S == "YES" orelse
  S == "on" orelse S == "On" orelse S == "ON").

-define(IS_FALSE(S),
  S == "false" orelse S == "False" orelse S == "FALSE" orelse
  S == "n" orelse S == "N" orelse
  S == "no" orelse S == "No" orelse S == "NO" orelse
  S == "off" orelse S == "Off" orelse S == "OFF").

%% -------------------------------------------------------------------
%% Public API.
%% -------------------------------------------------------------------

tags() -> [?TAG].

try_construct_token(Constr, Node,
  #yaml_scalar{tag = #yaml_tag{uri = {non_specific, "?"}},
  text = Text} = Token) when ?IS_TRUE(Text) orelse ?IS_FALSE(Text) ->
    construct_token(Constr, Node, Token);
try_construct_token(_, _, _) ->
    unrecognized.

construct_token(#yaml_constr{simple_structs = true},
  undefined, #yaml_scalar{text = Text}) when ?IS_TRUE(Text) ->
    {finished, true};
construct_token(#yaml_constr{simple_structs = true},
  undefined, #yaml_scalar{text = Text}) when ?IS_FALSE(Text) ->
    {finished, false};
construct_token(#yaml_constr{simple_structs = false},
  undefined, #yaml_scalar{text = Text} = Token) when ?IS_TRUE(Text) ->
    Pres = yaml_constr:get_pres_details(Token),
    Node = #yaml_bool{
      module = ?MODULE,
      tag    = ?TAG,
      pres   = Pres,
      value  = true
    },
    {finished, Node};
construct_token(#yaml_constr{simple_structs = false},
  undefined, #yaml_scalar{text = Text} = Token) when ?IS_FALSE(Text) ->
    Pres = yaml_constr:get_pres_details(Token),
    Node = #yaml_bool{
      module = ?MODULE,
      tag    = ?TAG,
      pres   = Pres,
      value  = false
    },
    {finished, Node}.

node_pres(Node) ->
    ?NODE_PRES(Node).