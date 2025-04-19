package haxe.ui.backend;

import haxe.io.Bytes;
import haxe.ui.assets.FontInfo;
import hxd.Res;
import hxd.fs.BytesFileSystem.BytesFileEntry;
import hxd.res.Image;

class AssetsImpl extends AssetsBase { 
    public function embedFontSupported():Bool {
        return #if (lime || flash || js) true #else false #end;
    }

    private override function getImageInternal(resourceId:String, callback:haxe.ui.assets.ImageInfo->Void) {
        // try {
        //     var loader:hxd.res.Loader = hxd.Res.loader;
        //     if (loader != null) {
        //         if (loader.exists(resourceId)) {
        //             var image:Image = loader.load(resourceId).toImage();
        //             var size:Dynamic = image.getSize();
        //             var imageInfo:haxe.ui.assets.ImageInfo = {
        //                 width: size.width,
        //                 height: size.height,
        //                 data: image.toBitmap()
        //             };
        //             callback(imageInfo);
        //         } else {
        //             callback(null);
        //         }
        //     } else {
        //         callback(null);
        //     }
        // } catch (e:Dynamic) {
        //     trace(e);
        //     callback(null);
        // }
        tools.AutoPak.loadImageForUi(resourceId, (loadedTile) -> {
           var imageInfo:haxe.ui.assets.ImageInfo = {
                width: loadedTile.width,
                height: loadedTile.height,
                data: loadedTile
           };
           callback(imageInfo);
        });
    }

    private override function getImageFromHaxeResource(resourceId:String, callback:String->haxe.ui.assets.ImageInfo->Void) {
        var bytes = Resource.getBytes(resourceId);
        imageFromBytes(bytes, function(imageInfo) {
            callback(resourceId, imageInfo);
        });
    }

    public override function imageFromBytes(bytes:Bytes, callback:haxe.ui.assets.ImageInfo->Void) {
        if (bytes == null) {
            callback(null);
            return;
        }

        try {
            var entry:BytesFileEntry = new BytesFileEntry("", bytes);
            var image:Image = new Image(entry);

            var size:Dynamic = image.getSize();
            var imageInfo:haxe.ui.assets.ImageInfo = {
                width: size.width,
                height: size.height,
                data: image.toBitmap()
            };
            callback(imageInfo);
        } catch (e:Dynamic) {
            callback(null);
        }
    }

    public override function imageInfoFromImageData(imageData:ImageData):haxe.ui.assets.ImageInfo {
        var imageInfo:haxe.ui.assets.ImageInfo = {
            width: imageData.width,
            height: imageData.height,
            data: imageData
        };
        return imageInfo;
    }
    
    private override function getFontInternal(resourceId:String, callback:FontInfo->Void) {
        try {
            var font = hxd.Res.loader.loadCache("fonts/" + resourceId + ".fnt", hxd.res.BitmapFont);
            //var font = Reflect.getProperty(assets.Assets, "font" + resourceId);
            callback({
                name: resourceId,
                data: font
            });
        } catch (error:Dynamic) {
            #if debug
            trace("WARNING: problem loading font '" + resourceId + "' (" + error + ")");
            #end
            callback(null);
        }
    }
}
