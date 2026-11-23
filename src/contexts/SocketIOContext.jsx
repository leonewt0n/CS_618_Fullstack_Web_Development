import { createContext, useState, useContext, useEffect } from 'react'
import { io } from 'socket.io-client'
import PropTypes from 'prop-types'
import { useAuth } from './AuthContext.jsx'

export const SocketIOContext = createContext({
  socket: null,
  status: 'waiting',
  error: null,
})

export const SocketIOContextProvider = ({ children }) => {
  const [socket, setSocket] = useState(null)
  const [status, setStatus] = useState('waiting')
  const [error, setError] = useState(null)

  const [token] = useAuth()

  useEffect(() => {
    if (!token) return undefined

    const connection = io(import.meta.env.VITE_SOCKET_HOST, {
      query: window.location.search.substring(1),
      auth: { token },
    })
    const onConnect = () => {
      setSocket(connection)
      setStatus('connected')
      setError(null)
    }
    const onError = (err) => {
      setStatus('error')
      setError(err)
    }
    const onDisconnect = () => setStatus('disconnected')

    connection.on('connect', onConnect)
    connection.on('connect_error', onError)
    connection.on('disconnect', onDisconnect)

    return () => {
      connection.off('connect', onConnect)
      connection.off('connect_error', onError)
      connection.disconnect()
      connection.off('disconnect', onDisconnect)
    }
  }, [token])

  return (
    <SocketIOContext.Provider value={{ socket, status, error }}>
      {children}
    </SocketIOContext.Provider>
  )
}

SocketIOContextProvider.propTypes = {
  children: PropTypes.element.isRequired,
}

export function useSocket() {
  return useContext(SocketIOContext)
}
