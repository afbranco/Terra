/**
 * This class is automatically generated by mig. DO NOT EDIT THIS FILE.
 * This class implements a Java interface to the 'reqProgBlockMsg'
 * message type.
 */

public class reqProgBlockMsg extends net.tinyos.message.Message {

    /** The default size of this message type in bytes. */
    public static final int DEFAULT_MESSAGE_SIZE = 16;

    /** The Active Message type associated with this message. */
    public static final int AM_TYPE = 162;

    /** Create a new reqProgBlockMsg of size 16. */
    public reqProgBlockMsg() {
        super(DEFAULT_MESSAGE_SIZE);
        amTypeSet(AM_TYPE);
    }

    /** Create a new reqProgBlockMsg of the given data_length. */
    public reqProgBlockMsg(int data_length) {
        super(data_length);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new reqProgBlockMsg with the given data_length
     * and base offset.
     */
    public reqProgBlockMsg(int data_length, int base_offset) {
        super(data_length, base_offset);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new reqProgBlockMsg using the given byte array
     * as backing store.
     */
    public reqProgBlockMsg(byte[] data) {
        super(data);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new reqProgBlockMsg using the given byte array
     * as backing store, with the given base offset.
     */
    public reqProgBlockMsg(byte[] data, int base_offset) {
        super(data, base_offset);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new reqProgBlockMsg using the given byte array
     * as backing store, with the given base offset and data length.
     */
    public reqProgBlockMsg(byte[] data, int base_offset, int data_length) {
        super(data, base_offset, data_length);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new reqProgBlockMsg embedded in the given message
     * at the given base offset.
     */
    public reqProgBlockMsg(net.tinyos.message.Message msg, int base_offset) {
        super(msg, base_offset, DEFAULT_MESSAGE_SIZE);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new reqProgBlockMsg embedded in the given message
     * at the given base offset and length.
     */
    public reqProgBlockMsg(net.tinyos.message.Message msg, int base_offset, int data_length) {
        super(msg, base_offset, data_length);
        amTypeSet(AM_TYPE);
    }

    /**
    /* Return a String representation of this message. Includes the
     * message type name and the non-indexed field values.
     */
    public String toString() {
      String s = "Message <reqProgBlockMsg> \n";
      try {
        s += "  [reqOper=0x"+Long.toHexString(get_reqOper())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [versionId=0x"+Long.toHexString(get_versionId())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [blockId=0x"+Long.toHexString(get_blockId())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [refTA1=0x"+Long.toHexString(get_refTA1())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [refTB1=0x"+Long.toHexString(get_refTB1())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [refTB2=0x"+Long.toHexString(get_refTB2())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      return s;
    }

    // Message-type-specific access methods appear below.

    /////////////////////////////////////////////////////////
    // Accessor methods for field: reqOper
    //   Field type: short, unsigned
    //   Offset (bits): 0
    //   Size (bits): 8
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'reqOper' is signed (false).
     */
    public static boolean isSigned_reqOper() {
        return false;
    }

    /**
     * Return whether the field 'reqOper' is an array (false).
     */
    public static boolean isArray_reqOper() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'reqOper'
     */
    public static int offset_reqOper() {
        return (0 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'reqOper'
     */
    public static int offsetBits_reqOper() {
        return 0;
    }

    /**
     * Return the value (as a short) of the field 'reqOper'
     */
    public short get_reqOper() {
        return (short)getUIntBEElement(offsetBits_reqOper(), 8);
    }

    /**
     * Set the value of the field 'reqOper'
     */
    public void set_reqOper(short value) {
        setUIntBEElement(offsetBits_reqOper(), 8, value);
    }

    /**
     * Return the size, in bytes, of the field 'reqOper'
     */
    public static int size_reqOper() {
        return (8 / 8);
    }

    /**
     * Return the size, in bits, of the field 'reqOper'
     */
    public static int sizeBits_reqOper() {
        return 8;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: versionId
    //   Field type: int, unsigned
    //   Offset (bits): 8
    //   Size (bits): 16
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'versionId' is signed (false).
     */
    public static boolean isSigned_versionId() {
        return false;
    }

    /**
     * Return whether the field 'versionId' is an array (false).
     */
    public static boolean isArray_versionId() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'versionId'
     */
    public static int offset_versionId() {
        return (8 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'versionId'
     */
    public static int offsetBits_versionId() {
        return 8;
    }

    /**
     * Return the value (as a int) of the field 'versionId'
     */
    public int get_versionId() {
        return (int)getUIntBEElement(offsetBits_versionId(), 16);
    }

    /**
     * Set the value of the field 'versionId'
     */
    public void set_versionId(int value) {
        setUIntBEElement(offsetBits_versionId(), 16, value);
    }

    /**
     * Return the size, in bytes, of the field 'versionId'
     */
    public static int size_versionId() {
        return (16 / 8);
    }

    /**
     * Return the size, in bits, of the field 'versionId'
     */
    public static int sizeBits_versionId() {
        return 16;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: blockId
    //   Field type: short, unsigned
    //   Offset (bits): 24
    //   Size (bits): 8
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'blockId' is signed (false).
     */
    public static boolean isSigned_blockId() {
        return false;
    }

    /**
     * Return whether the field 'blockId' is an array (false).
     */
    public static boolean isArray_blockId() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'blockId'
     */
    public static int offset_blockId() {
        return (24 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'blockId'
     */
    public static int offsetBits_blockId() {
        return 24;
    }

    /**
     * Return the value (as a short) of the field 'blockId'
     */
    public short get_blockId() {
        return (short)getUIntBEElement(offsetBits_blockId(), 8);
    }

    /**
     * Set the value of the field 'blockId'
     */
    public void set_blockId(short value) {
        setUIntBEElement(offsetBits_blockId(), 8, value);
    }

    /**
     * Return the size, in bytes, of the field 'blockId'
     */
    public static int size_blockId() {
        return (8 / 8);
    }

    /**
     * Return the size, in bits, of the field 'blockId'
     */
    public static int sizeBits_blockId() {
        return 8;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: refTA1
    //   Field type: long, unsigned
    //   Offset (bits): 32
    //   Size (bits): 32
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'refTA1' is signed (false).
     */
    public static boolean isSigned_refTA1() {
        return false;
    }

    /**
     * Return whether the field 'refTA1' is an array (false).
     */
    public static boolean isArray_refTA1() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'refTA1'
     */
    public static int offset_refTA1() {
        return (32 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'refTA1'
     */
    public static int offsetBits_refTA1() {
        return 32;
    }

    /**
     * Return the value (as a long) of the field 'refTA1'
     */
    public long get_refTA1() {
        return (long)getUIntBEElement(offsetBits_refTA1(), 32);
    }

    /**
     * Set the value of the field 'refTA1'
     */
    public void set_refTA1(long value) {
        setUIntBEElement(offsetBits_refTA1(), 32, value);
    }

    /**
     * Return the size, in bytes, of the field 'refTA1'
     */
    public static int size_refTA1() {
        return (32 / 8);
    }

    /**
     * Return the size, in bits, of the field 'refTA1'
     */
    public static int sizeBits_refTA1() {
        return 32;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: refTB1
    //   Field type: long, unsigned
    //   Offset (bits): 64
    //   Size (bits): 32
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'refTB1' is signed (false).
     */
    public static boolean isSigned_refTB1() {
        return false;
    }

    /**
     * Return whether the field 'refTB1' is an array (false).
     */
    public static boolean isArray_refTB1() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'refTB1'
     */
    public static int offset_refTB1() {
        return (64 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'refTB1'
     */
    public static int offsetBits_refTB1() {
        return 64;
    }

    /**
     * Return the value (as a long) of the field 'refTB1'
     */
    public long get_refTB1() {
        return (long)getUIntBEElement(offsetBits_refTB1(), 32);
    }

    /**
     * Set the value of the field 'refTB1'
     */
    public void set_refTB1(long value) {
        setUIntBEElement(offsetBits_refTB1(), 32, value);
    }

    /**
     * Return the size, in bytes, of the field 'refTB1'
     */
    public static int size_refTB1() {
        return (32 / 8);
    }

    /**
     * Return the size, in bits, of the field 'refTB1'
     */
    public static int sizeBits_refTB1() {
        return 32;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: refTB2
    //   Field type: long, unsigned
    //   Offset (bits): 96
    //   Size (bits): 32
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'refTB2' is signed (false).
     */
    public static boolean isSigned_refTB2() {
        return false;
    }

    /**
     * Return whether the field 'refTB2' is an array (false).
     */
    public static boolean isArray_refTB2() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'refTB2'
     */
    public static int offset_refTB2() {
        return (96 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'refTB2'
     */
    public static int offsetBits_refTB2() {
        return 96;
    }

    /**
     * Return the value (as a long) of the field 'refTB2'
     */
    public long get_refTB2() {
        return (long)getUIntBEElement(offsetBits_refTB2(), 32);
    }

    /**
     * Set the value of the field 'refTB2'
     */
    public void set_refTB2(long value) {
        setUIntBEElement(offsetBits_refTB2(), 32, value);
    }

    /**
     * Return the size, in bytes, of the field 'refTB2'
     */
    public static int size_refTB2() {
        return (32 / 8);
    }

    /**
     * Return the size, in bits, of the field 'refTB2'
     */
    public static int sizeBits_refTB2() {
        return 32;
    }

}
