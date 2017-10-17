#include <stdio.h>
#include <iostream>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <linux/videodev2.h>
#include <Leap.h>

using namespace std;
using namespace Leap;

int fd;

class SampleListener : public Listener {
public:
    virtual void onConnect(const Controller&);

    virtual void onImages(const Controller&);
};

void SampleListener::onConnect(const Controller& controller) {
    controller.setPolicy(Controller::POLICY_IMAGES);
}

void SampleListener::onImages(const Controller& controller) {

    static size_t single_size = 640 * 240;
    static size_t stereo_size = 640 * 480;
    static unsigned char buffer[640 * 480];

    ImageList images = controller.images();

    for (int img = 0; img < 2; img++) {
        memcpy(buffer + img * single_size, images[img].data(), single_size);
    }

    write(fd, buffer, stereo_size);
}

int main(int argc, char** argv) {

    if (argc < 2) {
        cerr << "Usage: exposeImages <videoDevice>" << endl;
        return 1;
    }

    if ((fd = open(argv[1], O_WRONLY)) == -1)
        cerr << "Unable to open video output!" << cerr;

    struct v4l2_format vid_format;
    memset(&vid_format, 0, sizeof(vid_format));
    vid_format.type = V4L2_BUF_TYPE_VIDEO_OUTPUT;

    vid_format.fmt.pix.width = 640;
    vid_format.fmt.pix.height = 480;
    vid_format.fmt.pix.pixelformat = V4L2_PIX_FMT_GREY;
    vid_format.fmt.pix.sizeimage = 640 * 480;
    vid_format.fmt.pix.field = V4L2_FIELD_NONE;

    if (ioctl(fd, VIDIOC_S_FMT, &vid_format) == -1)
        cerr << "Unable to set video format!" << endl;

    SampleListener listener;
    Controller controller;
    controller.addListener(listener);

    while (!controller.isConnected()) { }

    while (controller.isConnected()) {
        sleep(1);
    }

    controller.removeListener(listener);

    return 0;
}

