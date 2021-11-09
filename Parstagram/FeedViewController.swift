//
//  FeedViewController.swift
//  Parstagram
//
//  Created by YANWEN CHEN on 2021/11/4.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate{

    @IBOutlet weak var tableView: UITableView!
    
    let commentBar = MessageInputBar()
    var showsCommentBar = false
    var posts = [PFObject]()
    var selectedPost: PFObject!
    
    //temp here
    let myRefreshControl=UIRefreshControl()
    //end temp
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentBar.inputTextView.placeholder="Add a comment <3"
        commentBar.sendButton.title="Post"
        commentBar.delegate=self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.keyboardDismissMode = .interactive
        
        //temp here
        myRefreshControl.addTarget(self, action: #selector(viewDidAppear), for: .valueChanged)
        tableView.refreshControl = myRefreshControl
        //end temp

        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name:UIResponder.keyboardWillHideNotification, object:nil)
    }
    
    @objc func keyboardWillBeHidden(note: Notification){
        commentBar.inputTextView.text=nil
        showsCommentBar = false
        becomeFirstResponder()
    }
    
    
    override var inputAccessoryView: UIView?{
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool{
        return showsCommentBar
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let query = PFQuery(className: "Posts")
        query.includeKeys(["author","comments","comments.author"])
        query.limit = 50
        
        query.findObjectsInBackground { posts, error in
            if posts != nil{
                self.posts = posts!
                self.tableView.reloadData()
                //temp here
                self.myRefreshControl.endRefreshing()
                //end temp
            }
        }
    }
    
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        //create a comment
        let comment=PFObject(className: "Comments")
        comment["text"] = text
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()!

        selectedPost.add(comment, forKey: "comments")

        selectedPost.saveInBackground { (success, error) in
            if success{
                print("Comment saved")
            }
            else{
                print("Error saving comment")
            }
        }
        
        
        tableView.reloadData()
        
        //clear and mismiss the input bar
        commentBar.inputTextView.text=nil
        showsCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
    /*//temp1 here
    func loadMoreImages(){
        let query = PFQuery(className: "Posts")
        query.includeKey("author")
        query.limit = query.limit + 20
        
        query.findObjectsInBackground { posts, error in
            if posts != nil{
                self.posts = posts!
                self.tableView.reloadData()
                //temp here
                self.myRefreshControl.endRefreshing()
                //end temp
            }
        }
    }
  
    //end temp1
    */
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post=posts[section]
        let comments=(post["comments"] as? [PFObject]) ?? []
        return comments.count + 2
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post=posts[indexPath.section]
        
        let comments=(post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == 0{
            let cell=tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
           
            let user=post["author"] as! PFUser
            cell.usernameLabel.text = user.username
            cell.captionLabel.text = post["caption"] as! String
            
            let imageFile=post["image"] as! PFFileObject
            let urlString=imageFile.url!
            let url=URL(string: urlString)!
            
            cell.photoView.af_setImage(withURL: url)
            
            return cell
            
        } else if indexPath.row <= comments.count{
            let cell=tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            let comment = comments[indexPath.row-1]
            cell.commentLabel.text=comment["text"] as? String
            
            let user=comment["author"] as! PFUser
            cell.nameLabel.text=user.username
            return cell
        } else{
            let cell=tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            return cell
        }
        
    }
    

    @IBAction func onLogoutButton(_ sender: Any) {
        PFUser.logOut()
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let delegate = windowScene.delegate as? SceneDelegate else {return}
        
        delegate.window?.rootViewController = loginViewController
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        if indexPath.row == comments.count + 1{
            showsCommentBar=true
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()
            
            selectedPost=post
            
        }
        

        
    }
    

}
