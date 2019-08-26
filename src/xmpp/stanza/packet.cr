module XMPP::Stanza
  enum PacketType
    Presence
    Message
    IQ
  end

  module Packet
    abstract def name : String
    abstract def to_xml(xml : XML::Builder) : String

    def to_xml
      val = XML.build(indent: "  ", quote_char: '"') do |xml|
        to_xml xml
      end
      val = val.sub(%(<?xml version="1.0"?>), "").lstrip("\n")
      val
    end
  end

  # Attrs represents the common structure for base XMPP packets.
  # ## "Type" Attribute
  #
  # Common uses of the message stanza in instant messaging applications
  # include: single messages; messages sent in the context of a one-to-one
  # chat session; messages sent in the context of a multi-user chat room;
  # alerts, notifications, or other information to which no reply is expected;
  # and errors. These uses are differentiated via the `type` attribute. If
  # included, the `type` attribute MUST have one of the following values:
  #
  # * `:chat` -- The message is sent in the context of a one-to-one chat
  #   session. Typically a receiving client will present message of type
  #   `chat` in an interface that enables one-to-one chat between the two
  #   parties, including an appropriate conversation history.
  #
  # * `:error` -- The message is generated by an entity that experiences an
  #   error in processing a message received from another entity. A client
  #   that receives a message of type `error` SHOULD present an appropriate
  #   interface informing the sender of the nature of the error.
  #
  # * `:groupchat` -- The message is sent in the context of a multi-user chat
  #   environment (similar to that of [IRC]). Typically a receiving client
  #   will present a message of type `groupchat` in an interface that enables
  #   many-to-many chat between the parties, including a roster of parties in
  #   the chatroom and an appropriate conversation history.
  #
  # * `:headline` -- The message provides an alert, a notification, or other
  #   information to which no reply is expected (e.g., news headlines, sports
  #   updates, near-real-time market data, and syndicated content). Because no
  #   reply to the message is expected, typically a receiving client will
  #   present a message of type "headline" in an interface that appropriately
  #   differentiates the message from standalone messages, chat messages, or
  #   groupchat messages (e.g., by not providing the recipient with the
  #   ability to reply).
  #
  # * `:normal` -- The message is a standalone message that is sent outside
  #   the context of a one-to-one conversation or groupchat, and to which it
  #   is expected that the recipient will reply. Typically a receiving client
  #   will present a message of type `normal` in an interface that enables the
  #   recipient to reply, but without a conversation history. The default
  #   value of the `type` attribute is `normal`.
  # ## "To" Attribute
  #
  # An instant messaging client specifies an intended recipient for a message
  # by providing the JID of an entity other than the sender in the `to`
  # attribute of the Message stanza. If the message is being sent outside the
  # context of any existing chat session or received message, the value of the
  # `to` address SHOULD be of the form "user@domain" rather than of the form
  # "user@domain/resource".
  module Attrs
    property type : String = ""
    property id : String = ""
    property from : String = ""
    property to : String = ""
    property lang : String = ""
    getter xmlns : String = ""

    def load_attrs(node : XML::Node)
      @xmlns = node.namespace.try &.href || ""
      node.attributes.each do |attr|
        case attr.name
        when "type" then @type = attr.children[0].content
        when "id"   then @id = attr.children[0].content
        when "from" then @from = attr.children[0].content
        when "to"   then @to = attr.children[0].content
        when "lang" then @lang = attr.children[0].content
        end
      end
    end

    def attr_hash
      dict = Hash(String, String).new
      dict["xmlns"] = xmlns unless xmlns.blank?
      dict["type"] = type unless type.blank?
      dict["id"] = id unless id.blank?
      dict["from"] = from unless from.blank?
      dict["to"] = to unless to.blank?
      lang_ns = xmlns.blank? ? "lang" : "xml:lang"
      dict[lang_ns] = lang unless lang.blank?

      dict
    end
  end

  # RFC 6120: part of A.5 Client Namespace and A.6 Server Namespace
  IQ_TYPE_ERROR  = "error"
  IQ_TYPE_GET    = "get"
  IQ_TYPE_RESULT = "result"
  IQ_TYPE_SET    = "set"

  MESSAGE_TYPE_CHAT      = "chat"
  MESSAGE_TYPE_ERROR     = "error"
  MESSAGE_TYPE_GROUPCHAT = "groupchat"
  MESSAGE_TYPE_HEADLINE  = "headline"
  MESSAGE_TYPE_NORMAL    = "normal" # Default

  PRESENCE_TYPE_ERROR        = "error"
  PRESENCE_TYPE_PROBE        = "probe"
  PRESENCE_TYPE_SUBSCRIBE    = "subscribe"
  PRESENCE_TYPE_SUBSCRIBED   = "subscribed"
  PRESENCE_TYPE_UNAVAILABLE  = "unavailable"
  PRESENCE_TYPE_UNSUBSCRIBE  = "unsubscribe"
  PRESENCE_TYPE_UNSUBSCRIBED = "unsubscribed"
end
