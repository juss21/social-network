import React, { useState, useRef } from "react";
import { backendHost } from "../../../index.js";
import { FaImage } from "react-icons/fa";

const FeedPostCommentForm = ({
  userInfo,
  commentImageName,
  setCommentImageName,
  commentInputValue,
  setCommentInputValue,
  openedPostId,
  loadComments,
}) => {
  const [selectedCommentFile, setSelectedCommentFile] = useState(null);
  const commentFileInputRef = useRef(null);
  let firstName = userInfo.FirstName;
  let lastName = userInfo.LastName;
  let userName = userInfo.UserName;

  const handleCommentFormSubmit = (event) => {
    event.preventDefault();

    if (commentInputValue.trim() !== "") {
      const commentBody = {
        userID: userInfo.UserID,
        firstName,
        lastName,
        userName,
        content: commentInputValue,
        PostID: openedPostId,
      };

      const commentBodyString = JSON.stringify(commentBody);
      const blob = new Blob([commentBodyString], {
        type: "application/json",
      });

      const formData = new FormData();
      if (commentImageName !== undefined) {
        formData.append("file", selectedCommentFile); // Append the image file to the form data
      }
      formData.append("content", blob); // Append the text content to the form data

      fetch(`${backendHost}/savecomment`, {
        method: "POST",
        body: formData,
      })
        .then((response) => {
          if (response.ok) {
            loadComments(openedPostId);
            setCommentInputValue("");
            setCommentImageName(undefined);
          }
        })
        .catch((error) => {
          console.error("Error saving comment:", error);
        });
    }
  };
  const handleInputChange = (event) => {
    setCommentInputValue(event.target.value);
  };

  const handleFileChange = (event) => {
    const file = event.target.files[0];
    setSelectedCommentFile(file);
    setCommentImageName(file.name);
  };

  return (
    <form onSubmit={handleCommentFormSubmit}>
      <div className="comment-input-wrapper">
        <div className="comment-input-container">
          <input
            type="text"
            placeholder={`Write a comment...`}
            className="NewComment"
            value={commentInputValue}
            onChange={(e) => handleInputChange(e)}
          />
          <button
            type="button"
            className="file-upload-button"
            onClick={() => commentFileInputRef.current.click()}
          >
            <FaImage />
          </button>
          <input
            type="file"
            accept="image/*"
            onChange={(e) => handleFileChange(e)}
            ref={commentFileInputRef}
            className="hidden-file-input"
          />
          {commentImageName
            ? `Selected image: ${commentImageName}`
            : "Click here to select image."}
        </div>
        <button type="submit" className="comment-input-button">
          Post comment
        </button>
      </div>
    </form>
  );
};

export default FeedPostCommentForm;
