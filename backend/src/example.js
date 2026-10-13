import {initDatabase} from './db/init.js'
import { Post } from './db/models/post.js'

import dotenv from 'dotenv'
dotenv.config()

await initDatabase()

const post = new Post({
title: '2nd Post',
author: 'John Doe',
contents: 'This is a new post, from test script is stored in a MongoDB database using Mongoose.',
tags: ['mongoose', 'mongodb'],
})

await post.save()

const posts = await Post.find()
console.log(posts)