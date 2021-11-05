//
//  FeedViewController.swift
//  Parstagram
//
//  Created by YANWEN CHEN on 2021/11/4.
//

import UIKit
import Parse
import AlamofireImage

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    
    var posts = [PFObject]()
    
    //temp here
    let myRefreshControl=UIRefreshControl()
    //end temp
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        //temp here
        myRefreshControl.addTarget(self, action: #selector(viewDidAppear), for: .valueChanged)
        tableView.refreshControl = myRefreshControl
        //end temp

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let query = PFQuery(className: "Posts")
        query.includeKey("author")
        query.limit = 20
        
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
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        let post=posts[indexPath.row]
        let user=post["author"] as! PFUser
        cell.usernameLabel.text = user.username
        cell.captionLabel.text = post["caption"] as! String
        
        let imageFile=post["image"] as! PFFileObject
        let urlString=imageFile.url!
        let url=URL(string: urlString)!
        
        cell.photoView.af_setImage(withURL: url)
        
        return cell
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
