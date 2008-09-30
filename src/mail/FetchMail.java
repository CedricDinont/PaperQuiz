import java.util.*;
import java.io.*;
import javax.mail.*;
import javax.mail.event.*;
import javax.mail.internet.*;
import javax.activation.*;

public class FetchMail {

    URLName mailUrl = new URLName("pop3s://qcm.isen:isenisen@pop.gmail.com");
    String attachmentsOutputFolder;
    int nbSavedAttachments = 0;

    public FetchMail(String attachmentsOutputFolder) {
	this.attachmentsOutputFolder = attachmentsOutputFolder;
    }

    public void doFetch() {
	Properties props = new Properties();

	try {
	    Session session = Session.getInstance(props, null);
	    // session.setDebug(true);

	    Store store = session.getStore(mailUrl);

	    store.connect();

	    // Open the Folder
	    Folder folder = store.getDefaultFolder();
	    if (folder == null) {
	        System.out.println("No default folder");
	        System.exit(1);
	    }

	    String mbox = "INBOX";
	    folder = folder.getFolder(mbox);
	    if (folder == null) {
	        System.out.println("Invalid folder");
	        System.exit(1);
	    } 

	    folder.open(Folder.READ_WRITE);

	    int totalMessages = folder.getMessageCount();
	    if (totalMessages == 0) {
		System.out.println("Warning: No mail in inbox.");
		folder.close(false);
		store.close();
		System.exit(1);
	    }

	    System.out.println("Total messages = " + totalMessages);

	    Message[] msgs = folder.getMessages();

	    // Use a suitable FetchProfile
	    FetchProfile fp = new FetchProfile();
	    fp.add(FetchProfile.Item.ENVELOPE);
	    fp.add(FetchProfile.Item.FLAGS);
	    fp.add("X-Mailer");
	    folder.fetch(msgs, fp);

	    for (int i = 0; i < msgs.length; i++) {
		System.out.println("--------------------------");
		System.out.println("MESSAGE #" + (i + 1) + ":");
		dumpPart(msgs[i], 0);
	    }

	    // Delete messages
	    folder.setFlags(msgs, new Flags(Flags.Flag.DELETED), true);

	    // Dump out the Flags of the moved messages, to insure that
	    // all got deleted
	    for (int i = 0; i < msgs.length; i++) {
		if (!msgs[i].isSet(Flags.Flag.DELETED))
		    System.out.println("Problem: Message # " + msgs[i] + 
				       " not deleted.");
	    }

	    // Close folders and store
	    folder.close(true);
	    store.close();
	    System.out.println("--------------------------");
	    System.out.println(nbSavedAttachments + " attachments were saved.");

	}
	catch (Exception e) 
	    {
		e.printStackTrace();
	    }
	
    }

    public void dumpPart(Part p, int level) throws Exception {
	String ct = p.getContentType();

	if (p.isMimeType("multipart/*")) {
	    Multipart mp = (Multipart)p.getContent();
	    int count = mp.getCount();
	    for (int i = 0; i < count; i++)
		dumpPart(mp.getBodyPart(i), level + 1);
	} else if (p.isMimeType("message/rfc822")) {
	    // Nested message
	    dumpPart((Part) p.getContent(), level + 1);
	}

	if (level != 0 && !p.isMimeType("multipart/*")) {
	    String disp = p.getDisposition();
	    // many mailers don't include a Content-Disposition
	    if (disp == null || disp.equalsIgnoreCase(Part.ATTACHMENT)) {
		String attachmentFilename = p.getFileName();
		if (attachmentFilename == null) {
		    //   System.out.println("No filename: Can't write to disk.");
		    return ;
		}
		String filename = attachmentsOutputFolder + "/" + attachmentFilename;
		System.out.println("Saving attachment to file " + filename);
		try {
		    File f = new File(filename);
		    if (f.exists())
			throw new IOException("file exists");
		    ((MimeBodyPart) p).saveFile(f);
		    nbSavedAttachments++;
		} catch (IOException ex) {
		    System.out.println("Failed to save attachment: " + ex);
		}
	    }
	}
    }

    public static void main(String argv[]) {
	if (argv.length != 1) {
	    System.out.println("Usage: FetchMail attachments_output_folder.");
	    System.exit(1);
	}
	
	FetchMail f = new FetchMail(argv[0]);
	f.doFetch();
	System.exit(0);
    }
}