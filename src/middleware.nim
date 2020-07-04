#[
  zfcore web framework for nim language
  This framework if free to use and to modify
  License: BSD
  Author: Amru Rosyada
  Email: amru.rosyada@gmail.com
  Git: https://github.com/zendbit
]#

import
  asyncdispatch,
  sugar

# local
import
  route

from httpctx import HttpCtx

type
  Middleware* = ref object of RootObj
    #
    # Middleware
    # pre is callback for prerouting
    # post is callback for postrouting
    #
    pre: (ctx: HttpCtx) -> Future[bool]
    post: (ctx: HttpCtx, route: Route) -> Future[bool]

proc newMiddleware*(): Middleware =
  #
  # create new middleware
  #
  return Middleware()

proc beforeRoute*(
  self: Middleware,
  pre: (ctx: HttpCtx) -> Future[bool]) =
  #
  # add before route in middleware
  # this will always check on client request before routing process
  #
  self.pre = pre

proc afterRoute*(
  self: Middleware,
  post: (ctx: HttpCtx, route: Route) -> Future[bool]) =
  #
  # add after route in middleware
  # this will always check on client request after routing process
  #
  self.post = post

proc execBeforeRoute*(
  self: Middleware, ctx: HttpCtx): Future[bool] {.async.} =
  #
  # execute the before routing callback check
  #
  if not self.pre.isNil:
    return await self.pre(ctx)

proc execAfterRoute*(
  self: Middleware,
  ctx: HttpCtx,
  route: Route): Future[bool] {.async.} =
  #
  # execute the after routing callback check
  #
  if not self.post.isNil:
    return await self.post(ctx, route)