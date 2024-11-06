// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MiniSocial {
    // Structure for a Post
    struct Post {
        string message;
        address author;
        uint likeCount;
        uint commentCount;
        bool exists; // Indicates if the post exists
    }

    // Structure for a Comment
    struct Comment {
        string message;
        address commenter;
        uint likeCount;
        bool exists; // Indicates if the comment exists
    }

    // Array to store posts
    Post[] public posts;
    
    // Mapping to track likes on posts (postId => (userAddress => liked))
    mapping(uint => mapping(address => bool)) public postLikes;
    
    // Mapping to store comments for each post (postId => array of Comments)
    mapping(uint => Comment[]) public postComments;
    
    // Mapping to track likes on comments (postId => (commentIndex => (userAddress => liked)))
    mapping(uint => mapping(uint => mapping(address => bool))) public commentLikes;

    // Function to publish a new post
    function publishPost(string memory _message) public {
        posts.push(Post({
            message: _message,
            author: msg.sender,
            likeCount: 0,
            commentCount: 0,
            exists: true
        }));
    }

    // Function to like a post
    function likePost(uint _postId) public {
        require(_postId < posts.length, "Post does not exist");
        require(posts[_postId].exists, "Post has been deleted");
        require(!postLikes[_postId][msg.sender], "You have already liked this post");

        postLikes[_postId][msg.sender] = true;
        posts[_postId].likeCount++;
    }

    // Function to unlike a post
    function unlikePost(uint _postId) public {
        require(_postId < posts.length, "Post does not exist");
        require(posts[_postId].exists, "Post has been deleted");
        require(postLikes[_postId][msg.sender], "You haven't liked this post");

        postLikes[_postId][msg.sender] = false;
        posts[_postId].likeCount--;
    }

    // Function to add a comment to a post
    function addComment(uint _postId, string memory _message) public {
        require(_postId < posts.length, "Post does not exist");
        require(posts[_postId].exists, "Post has been deleted");

        postComments[_postId].push(Comment({
            message: _message,
            commenter: msg.sender,
            likeCount: 0,
            exists: true
        }));
        posts[_postId].commentCount++;
    }

    // Function to like a comment on a post
    function likeComment(uint _postId, uint _commentIndex) public {
        require(_postId < posts.length, "Post does not exist");
        require(posts[_postId].exists, "Post has been deleted");
        require(_commentIndex < postComments[_postId].length, "Comment does not exist");
        require(postComments[_postId][_commentIndex].exists, "Comment has been deleted");
        require(!commentLikes[_postId][_commentIndex][msg.sender], "You have already liked this comment");

        commentLikes[_postId][_commentIndex][msg.sender] = true;
        postComments[_postId][_commentIndex].likeCount++;
    }

    // Function to unlike a comment
    function unlikeComment(uint _postId, uint _commentIndex) public {
        require(_postId < posts.length, "Post does not exist");
        require(posts[_postId].exists, "Post has been deleted");
        require(_commentIndex < postComments[_postId].length, "Comment does not exist");
        require(postComments[_postId][_commentIndex].exists, "Comment has been deleted");
        require(commentLikes[_postId][_commentIndex][msg.sender], "You haven't liked this comment");

        commentLikes[_postId][_commentIndex][msg.sender] = false;
        postComments[_postId][_commentIndex].likeCount--;
    }

    // Function to delete a post (only the author can delete)
    function deletePost(uint _postId) public {
        require(_postId < posts.length, "Post does not exist");
        require(posts[_postId].exists, "Post has already been deleted");
        require(posts[_postId].author == msg.sender, "You are not the author of this post");

        posts[_postId].exists = false;
        posts[_postId].likeCount = 0;
        posts[_postId].commentCount = 0;
    }

    // Function to delete a comment (only the author can delete)
    function deleteComment(uint _postId, uint _commentIndex) public {
        require(_postId < posts.length, "Post does not exist");
        require(posts[_postId].exists, "Post has been deleted");
        require(_commentIndex < postComments[_postId].length, "Comment does not exist");
        require(postComments[_postId][_commentIndex].exists, "Comment has already been deleted");
        require(postComments[_postId][_commentIndex].commenter == msg.sender, "You are not the author of this comment");

        postComments[_postId][_commentIndex].exists = false;
        postComments[_postId][_commentIndex].likeCount = 0;
    }

    // Function to retrieve a post by index
    function getPost(uint _postId) public view returns (string memory, address, uint, uint, bool) {
        require(_postId < posts.length, "Post does not exist");
        Post storage post = posts[_postId];
        return (post.message, post.author, post.likeCount, post.commentCount, post.exists);
    }

    // Function to retrieve a comment by index of a post
    function getComment(uint _postId, uint _commentIndex) public view returns (string memory, address, uint, bool) {
        require(_postId < posts.length, "Post does not exist");
        require(_commentIndex < postComments[_postId].length, "Comment does not exist");

        Comment storage comment = postComments[_postId][_commentIndex];
        return (comment.message, comment.commenter, comment.likeCount, comment.exists);
    }

    // Function to get the total number of posts
    function getTotalPosts() public view returns (uint) {
        return posts.length;
    }

    // Function to get the total number of comments on a post
    function getTotalComments(uint _postId) public view returns (uint) {
        require(_postId < posts.length, "Post does not exist");
        return postComments[_postId].length;
    }

    // Function to get the total number of likes on a post
    function getPostLikes(uint _postId) public view returns (uint) {
        require(_postId < posts.length, "Post does not exist");
        return posts[_postId].likeCount;
    }
}
