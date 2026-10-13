import mongoose, {Schema} from 'mongoose';
const postSchema = new Schema({
    title: {type: String, required: true},
    author: {type: String},
    contents: {type: String},
    tags: {type: [String]},
}, 
    {timestamps: true}
)
export const Post = mongoose.model('Post', postSchema)