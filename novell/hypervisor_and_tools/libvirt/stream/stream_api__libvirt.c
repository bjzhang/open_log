/**
 * virStreamSend:
 * @stream: pointer to the stream object
 * @data: buffer to write to stream
 * @nbytes: size of @data buffer
 *
 * Write a series of bytes to the stream. This method may
 * block the calling application for an arbitrary amount
 * of time. Once an application has finished sending data
 * it should call virStreamFinish to wait for successful
 * confirmation from the driver, or detect any error.
 *
 * This method may not be used if a stream source has been
 * registered.
 *
 * Errors are not guaranteed to be reported synchronously
 * with the call, but may instead be delayed until a
 * subsequent call.
 *
 * An example using this with a hypothetical file upload
 * API looks like
 *
 *     virStreamPtr st = virStreamNew(conn, 0);
 *     int fd = open("demo.iso", O_RDONLY);
 *
 *     virConnectUploadFile(conn, "demo.iso", st);
 *
 *     while (1) {
 *          char buf[1024];
 *          int got = read(fd, buf, 1024);
 *          if (got < 0) {
 *             virStreamAbort(st);
 *             break;
 *          }
 *          if (got == 0) {
 *             virStreamFinish(st);
 *             break;
 *          }
 *          int offset = 0;
 *          while (offset < got) {
 *             int sent = virStreamSend(st, buf+offset, got-offset);
 *             if (sent < 0) {
 *                virStreamAbort(st);
 *                goto done;
 *             }
 *             offset += sent;
 *          }
 *      }
 *      if (virStreamFinish(st) < 0)
 *         ... report an error ....
 *    done:
 *      virStreamFree(st);
 *      close(fd);
 *
 * Returns the number of bytes written, which may be less
 * than requested.
 *
 * Returns -1 upon error, at which time the stream will
 * be marked as aborted, and the caller should now release
 * the stream with virStreamFree.
 *
 * Returns -2 if the outgoing transmit buffers are full &
 * the stream is marked as non-blocking.
 */
int
virStreamSend(virStreamPtr stream,
              const char *data,
              size_t nbytes)
{
    VIR_DEBUG("stream=%p, data=%p, nbytes=%zi", stream, data, nbytes);

    virResetLastError();

    virCheckStreamReturn(stream, -1);
    virCheckNonNullArgGoto(data, error);

    if (stream->driver &&
        stream->driver->streamSend) {
        int ret;
        ret = (stream->driver->streamSend)(stream, data, nbytes);
        if (ret == -2)
            return -2;
        if (ret < 0)
            goto error;
        return ret;
    }

    virReportUnsupportedError();

 error:
    virDispatchError(stream->conn);
    return -1;
}


/**
 * virStreamRecv:
 * @stream: pointer to the stream object
 * @data: buffer to read into from stream
 * @nbytes: size of @data buffer
 *
 * Reads a series of bytes from the stream. This method may
 * block the calling application for an arbitrary amount
 * of time.
 *
 * Errors are not guaranteed to be reported synchronously
 * with the call, but may instead be delayed until a
 * subsequent call.
 *
 * An example using this with a hypothetical file download
 * API looks like
 *
 *     virStreamPtr st = virStreamNew(conn, 0);
 *     int fd = open("demo.iso", O_WRONLY, 0600);
 *
 *     virConnectDownloadFile(conn, "demo.iso", st);
 *
 *     while (1) {
 *         char buf[1024];
 *         int got = virStreamRecv(st, buf, 1024);
 *         if (got < 0)
 *            break;
 *         if (got == 0) {
 *            virStreamFinish(st);
 *            break;
 *         }
 *         int offset = 0;
 *         while (offset < got) {
 *            int sent = write(fd, buf + offset, got - offset);
 *            if (sent < 0) {
 *               virStreamAbort(st);
 *               goto done;
 *            }
 *            offset += sent;
 *         }
 *     }
 *     if (virStreamFinish(st) < 0)
 *        ... report an error ....
 *   done:
 *     virStreamFree(st);
 *     close(fd);
 *
 *
 * Returns the number of bytes read, which may be less
 * than requested.
 *
 * Returns 0 when the end of the stream is reached, at
 * which time the caller should invoke virStreamFinish()
 * to get confirmation of stream completion.
 *
 * Returns -1 upon error, at which time the stream will
 * be marked as aborted, and the caller should now release
 * the stream with virStreamFree.
 *
 * Returns -2 if there is no data pending to be read & the
 * stream is marked as non-blocking.
 */
int
virStreamRecv(virStreamPtr stream,
              char *data,
              size_t nbytes)
{
    VIR_DEBUG("stream=%p, data=%p, nbytes=%zi", stream, data, nbytes);

    virResetLastError();

    virCheckStreamReturn(stream, -1);
    virCheckNonNullArgGoto(data, error);

    if (stream->driver &&
        stream->driver->streamRecv) {
        int ret;
        ret = (stream->driver->streamRecv)(stream, data, nbytes);
        if (ret == -2)
            return -2;
        if (ret < 0)
            goto error;
        return ret;
    }

    virReportUnsupportedError();

 error:
    virDispatchError(stream->conn);
    return -1;
}


/**
 * virStreamSendAll:
 * @stream: pointer to the stream object
 * @handler: source callback for reading data from application
 * @opaque: application defined data
 *
 * Send the entire data stream, reading the data from the
 * requested data source. This is simply a convenient alternative
 * to virStreamSend, for apps that do blocking-I/O.
 *
 * An example using this with a hypothetical file upload
 * API looks like
 *
 *   int mysource(virStreamPtr st, char *buf, int nbytes, void *opaque) {
 *       int *fd = opaque;
 *
 *       return read(*fd, buf, nbytes);
 *   }
 *
 *   virStreamPtr st = virStreamNew(conn, 0);
 *   int fd = open("demo.iso", O_RDONLY);
 *
 *   virConnectUploadFile(conn, st);
 *   if (virStreamSendAll(st, mysource, &fd) < 0) {
 *      ...report an error ...
 *      goto done;
 *   }
 *   if (virStreamFinish(st) < 0)
 *      ...report an error...
 *   virStreamFree(st);
 *   close(fd);
 *
 * Returns 0 if all the data was successfully sent. The caller
 * should invoke virStreamFinish(st) to flush the stream upon
 * success and then virStreamFree
 *
 * Returns -1 upon any error, with virStreamAbort() already
 * having been called,  so the caller need only call
 * virStreamFree()
 */
int
virStreamSendAll(virStreamPtr stream,
                 virStreamSourceFunc handler,
                 void *opaque)
{
    char *bytes = NULL;
    int want = 1024*64;
    int ret = -1;
    VIR_DEBUG("stream=%p, handler=%p, opaque=%p", stream, handler, opaque);

    virResetLastError();

    virCheckStreamReturn(stream, -1);
    virCheckNonNullArgGoto(handler, cleanup);

    if (stream->flags & VIR_STREAM_NONBLOCK) {
        virReportError(VIR_ERR_OPERATION_INVALID, "%s",
                       _("data sources cannot be used for non-blocking streams"));
        goto cleanup;
    }

    if (VIR_ALLOC_N(bytes, want) < 0)
        goto cleanup;

    for (;;) {
        int got, offset = 0;
        got = (handler)(stream, bytes, want, opaque);
        if (got < 0) {
            virStreamAbort(stream);
            goto cleanup;
        }
        if (got == 0)
            break;
        while (offset < got) {
            int done;
            done = virStreamSend(stream, bytes + offset, got - offset);
            if (done < 0)
                goto cleanup;
            offset += done;
        }
    }
    ret = 0;

 cleanup:
    VIR_FREE(bytes);

    if (ret != 0)
        virDispatchError(stream->conn);

    return ret;
}


/**
 * virStreamRecvAll:
 * @stream: pointer to the stream object
 * @handler: sink callback for writing data to application
 * @opaque: application defined data
 *
 * Receive the entire data stream, sending the data to the
 * requested data sink. This is simply a convenient alternative
 * to virStreamRecv, for apps that do blocking-I/O.
 *
 * An example using this with a hypothetical file download
 * API looks like
 *
 *   int mysink(virStreamPtr st, const char *buf, int nbytes, void *opaque) {
 *       int *fd = opaque;
 *
 *       return write(*fd, buf, nbytes);
 *   }
 *
 *   virStreamPtr st = virStreamNew(conn, 0);
 *   int fd = open("demo.iso", O_WRONLY);
 *
 *   virConnectUploadFile(conn, st);
 *   if (virStreamRecvAll(st, mysink, &fd) < 0) {
 *      ...report an error ...
 *      goto done;
 *   }
 *   if (virStreamFinish(st) < 0)
 *      ...report an error...
 *   virStreamFree(st);
 *   close(fd);
 *
 * Returns 0 if all the data was successfully received. The caller
 * should invoke virStreamFinish(st) to flush the stream upon
 * success and then virStreamFree
 *
 * Returns -1 upon any error, with virStreamAbort() already
 * having been called,  so the caller need only call
 * virStreamFree()
 */
int
virStreamRecvAll(virStreamPtr stream,
                 virStreamSinkFunc handler,
                 void *opaque)
{
    char *bytes = NULL;
    int want = 1024*64;
    int ret = -1;
    VIR_DEBUG("stream=%p, handler=%p, opaque=%p", stream, handler, opaque);

    virResetLastError();

    virCheckStreamReturn(stream, -1);
    virCheckNonNullArgGoto(handler, cleanup);

    if (stream->flags & VIR_STREAM_NONBLOCK) {
        virReportError(VIR_ERR_OPERATION_INVALID, "%s",
                       _("data sinks cannot be used for non-blocking streams"));
        goto cleanup;
    }


    if (VIR_ALLOC_N(bytes, want) < 0)
        goto cleanup;

    for (;;) {
        int got, offset = 0;
        got = virStreamRecv(stream, bytes, want);
        if (got < 0)
            goto cleanup;
        if (got == 0)
            break;
        while (offset < got) {
            int done;
            done = (handler)(stream, bytes + offset, got - offset, opaque);
            if (done < 0) {
                virStreamAbort(stream);
                goto cleanup;
            }
            offset += done;
        }
    }
    ret = 0;

 cleanup:
    VIR_FREE(bytes);

    if (ret != 0)
        virDispatchError(stream->conn);

    return ret;
}

