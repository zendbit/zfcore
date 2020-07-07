#[
  zfcore web framework for nim language
  This framework if free to use and to modify
  License: BSD
  Author: Amru Rosyada
  Email: amru.rosyada@gmail.com
  Git: https://github.com/zendbit
]#

import
  os,
  sugar,
  sequtils

from zfblast import SslSettings

type
  Settings* = ref object
    #
    # This is setting definition
    # will be much changes on the future:
    #   port:int -> port to be use for the sever
    #   staticDir:string -> where the static directory, and will serve public resource like .css, .jpg, .js etc
    #   address:string -> is address to be bind for starting the server
    #
    # port to zfblast ssl setting
    # SslSettings* = ref object
    #    certFile*: string
    #    keyFile*: string
    #
    port*: int
    address*: string
    reuseAddress*: bool
    reusePort*: bool
    maxBodyLength*: int
    trace*: bool
    appRootDir*: string
    sslSettings*: SslSettings
    # Keep-Alive header max request with given persistent timeout
    # read RFC (https://tools.ietf.org/html/rfc2616)
    # section Keep-Alive and Connection
    # for improving response performance
    keepAliveMax*: int
    # Keep-Alive timeout
    keepAliveTimeout*: int
    staticDir*: string
    tmpDir*: string
    tmpUploadDir*: string
    tmpGzipDir*: string
    tmpBodyDir*: string
    readBodyBuffer*: int
    tmpCleanupDir*: seq[tuple[dirName: string, interval: int64]]

proc addTmpCleanupDir*(self: Settings, dirName: string, interval: int64 = 3600) =
  if filter(self.tmpCleanupDir, (x: tuple[dirName: string, interval: int64]) => x.dirName == dirName).len == 0:
    self.tmpCleanupDir.add((dirName, interval))
    
proc removeTmpCleanupDir*(self: Settings, dirname: string) =
  self.tmpCleanupDir = filter(self.tmpCleanupDir, (x: tuple[dirName: string, interval: int64]) => x.dirName != dirname)

proc newSettings*(
  appRootDir:string = getAppDir(),
  port: int = 8080,
  address: string = "0.0.0.0",
  reuseAddress: bool = true,
  reusePort: bool = false,
  maxBodyLength: int = 268435456,
  readBodyBuffer: int = 1024,
  trace: bool = false,
  keepAliveMax: int = 20,
  keepAliveTimeout: int = 10,
  sslSettings: SslSettings = nil,
  tmpCleanupDir: seq[tuple[dirName: string, interval: int64]] = @[]): Settings =
  #
  # this for instantiate new Settings with default parameter is:
  #   port -> 8080
  #   address -> 0.0.0.0
  #   staticDir -> www
  #
  var instance = Settings(
    port: port,
    address: address,
    staticDir: appRootDir.joinPath("www"),
    tmpDir: appRootDir.joinPath(".tmp"),
    tmpUploadDir: appRootDir.joinPath(".tmp", "upload"),
    tmpGzipDir: appRootDir.joinPath(".tmp", "gzip"),
    tmpBodyDir: appRootDir.joinPath(".tmp", "body"),
    tmpCleanupDir: tmpCleanupDir,
    reuseAddress: reuseAddress,
    reusePort: reusePort,
    maxBodyLength: maxBodyLength,
    readBodyBuffer: readBodyBuffer,
    trace: trace,
    keepAliveMax: keepAliveMax,
    keepAliveTimeout: keepAliveTimeout,
    sslSettings: sslSettings)

  if not instance.tmpDir.existsDir:
    instance.tmpDir.createDir
  if not instance.tmpUploadDir.existsDir:
    instance.tmpUploadDir.createDir
  if not instance.tmpGzipDir.existsDir:
    instance.tmpGzipDir.createDir
  if not instance.tmpBodyDir.existsDir:
    instance.tmpBodyDir.createDir

  instance.addTmpCleanupDir("upload")
  instance.addTmpCleanupDir("gzip")

  return instance

export
  SslSettings
