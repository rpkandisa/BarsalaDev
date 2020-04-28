//added by Kandisa Technologies on 20-12-2018
//It is used to parse JSON string when system hit ticket Comment APIs
public class ZendeskcommentJSON {

	public List<Comments> comments {get;set;} 
	public Object next_page {get;set;} 
	public Object previous_page {get;set;} 
	public Integer count {get;set;} 

	public ZendeskcommentJSON(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'comments') {
						comments = arrayOfComments(parser);
					} else if (text == 'next_page') {
						next_page = parser.readValueAs(Object.class);
					} else if (text == 'previous_page') {
						previous_page = parser.readValueAs(Object.class);
					} else if (text == 'count') {
						count = parser.getIntegerValue();
					} else {
						////System.debug(LoggingLevel.WARN, 'ZendeskcommentJSON consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	public class Comments {
		public Long id {get;set;} 
		public String type_Z {get;set;} // in json: type
		public Long author_id {get;set;} 
		public String body {get;set;} 
		public String html_body {get;set;} 
		public String plain_body {get;set;} 
		public Boolean public_Z {get;set;} // in json: public
		public List<Attachments> attachments {get;set;} 
		public Long audit_id {get;set;} 
		public String created_at {get;set;} 

		public Comments(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'id') {
							id = parser.getLongValue();
						} else if (text == 'type') {
							type_Z = parser.getText();
						} else if (text == 'author_id') {
							author_id = parser.getLongValue();
						} else if (text == 'body') {
							body = parser.getText();
						} else if (text == 'html_body') {
							html_body = parser.getText();
						} else if (text == 'plain_body') {
							plain_body = parser.getText();
						} else if (text == 'public') {
							public_Z = parser.getBooleanValue();
						} else if (text == 'attachments') {
							attachments = arrayOfAttachments(parser);
						} else if (text == 'audit_id') {
							audit_id = parser.getLongValue();
						} else if (text == 'created_at') {
							created_at = parser.getText();
						} else {
							////System.debug(LoggingLevel.WARN, 'Comments consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Thumbnails {
		public String url {get;set;} 
		public Long id {get;set;} 
		public String file_name {get;set;} 
		public String content_url {get;set;} 
		public String mapped_content_url {get;set;} 
		public String content_type {get;set;} 
		public Integer size {get;set;} 
		public Integer width {get;set;} 
		public Integer height {get;set;} 
		public Boolean inline {get;set;} 

		public Thumbnails(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'url') {
							url = parser.getText();
						} else if (text == 'id') {
							id = parser.getLongValue();
						} else if (text == 'file_name') {
							file_name = parser.getText();
						} else if (text == 'content_url') {
							content_url = parser.getText();
						} else if (text == 'mapped_content_url') {
							mapped_content_url = parser.getText();
						} else if (text == 'content_type') {
							content_type = parser.getText();
						} else if (text == 'size') {
							size = parser.getIntegerValue();
						} else if (text == 'width') {
							width = parser.getIntegerValue();
						} else if (text == 'height') {
							height = parser.getIntegerValue();
						} else if (text == 'inline') {
							inline = parser.getBooleanValue();
						} else {
							////System.debug(LoggingLevel.WARN, 'Thumbnails consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Attachments {
		public String url {get;set;} 
		public Long id {get;set;} 
		public String file_name {get;set;} 
		public String content_url {get;set;} 
		public String mapped_content_url {get;set;} 
		public String content_type {get;set;} 
		public Integer size {get;set;} 
		public Integer width {get;set;} 
		public Integer height {get;set;} 
		public Boolean inline {get;set;} 
		public List<Thumbnails> thumbnails {get;set;} 

		public Attachments(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'url') {
							url = parser.getText();
						} else if (text == 'id') {
							id = parser.getLongValue();
						} else if (text == 'file_name') {
							file_name = parser.getText();
						} else if (text == 'content_url') {
							content_url = parser.getText();
						} else if (text == 'mapped_content_url') {
							mapped_content_url = parser.getText();
						} else if (text == 'content_type') {
							content_type = parser.getText();
						} else if (text == 'size') {
							size = parser.getIntegerValue();
						} else if (text == 'width') {
							width = parser.getIntegerValue();
						} else if (text == 'height') {
							height = parser.getIntegerValue();
						} else if (text == 'inline') {
							inline = parser.getBooleanValue();
						} else if (text == 'thumbnails') {
							thumbnails = arrayOfThumbnails(parser);
						} else {
							////System.debug(LoggingLevel.WARN, 'Attachments consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public static ZendeskcommentJSON parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new ZendeskcommentJSON(parser);
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}

    private static List<Thumbnails> arrayOfThumbnails(System.JSONParser p) {
        List<Thumbnails> res = new List<Thumbnails>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Thumbnails(p));
        }
        return res;
    }

    private static List<Attachments> arrayOfAttachments(System.JSONParser p) {
        List<Attachments> res = new List<Attachments>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Attachments(p));
        }
        return res;
    }

    private static List<Comments> arrayOfComments(System.JSONParser p) {
        List<Comments> res = new List<Comments>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Comments(p));
        }
        return res;
    }
}