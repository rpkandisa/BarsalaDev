global with sharing class DeleteSharinpixImage {
  global static void deleteImage(Id recordId) {
    String result = 'failed';
    sharinpix.Utils spUtils = new sharinpix.Utils();
    List<Object> imglist;
    if (!Test.isrunningTest()) {
      imglist = spUtils.getAlbumImageIds(recordId);
    } else {
      imglist = new List<Object>{ 'd7eb26dd-2989-4e06-9eb9-d73323644b34' };
    }

    for (Object img : imglist) {
      string imageId = String.valueOf(img);
      //Map<String, Object> tagMap = (Map<String, Object>) img;
      //System.debug('imgdata@@@@ ' + imageId);

      Map<String, Object> claims = new Map<String, Object>{
        'abilities' => new Map<String, Object>{
          recordId => new Map<String, Object>{
            'Access' => new Map<String, Object>{ 'image_delete' => true }
          }
        }
      };
      try {
        sharinpix.Client.getInstance().destroy('/images/' + imageId, claims);
        result = 'success';
      } catch (Exception e) {
        result = e.getMessage();
      }
    }
  }
}