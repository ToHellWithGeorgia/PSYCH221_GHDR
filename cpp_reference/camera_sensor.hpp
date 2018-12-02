#pragma once

#include <array>
#include <map>
#include <memory>
#include <set>
#include <cstring>
#include <vector>
#include "image.hpp"
#include "pixel.hpp"

// Simple container class for sensor data output by camera. Basically a
// container for a statically sized 2D array.
template<typename T> class CameraSensorData {
 public:
  CameraSensorData(int width, int height)
      : width_(width), height_(height), data_(new T[width_ * height_]) {}

  ~CameraSensorData() { delete[] data_; }  // data_ is always new'ed.

  // Returns the width (in pixels) of the sensor output data. This may not be
  // the same as the width of the original sensor, if the user requested a crop
  // window.
  int width() const { return width_; }

  // Returns the height (in pixels) of the sensor output data. This may not be
  // the same as the height of the original sensor, if the user requested a crop
  // window.
  int height() const { return height_; }

  // Getters for specific data elements in the sensor data. Returns a reference
  // to a floating point intensity value. row = 0, col = 0 refers to the top
  // left pixel. row spans the vertical dimension (i.e. row in [0, height - 1]),
  // and col spans the horizontal dimension (i.e. col in [0, width - 1]).
  const T& data(int row, int col) const { return data_[row * width_ + col]; }
  T& data(int row, int col) { return data_[row * width_ + col]; }

  // A method to create a new copy of this sensor data.
  std::unique_ptr<CameraSensorData> Clone() const {
    std::unique_ptr<CameraSensorData> clone(
        new CameraSensorData(width_, height_));
    std::memcpy(clone->data_, data_, sizeof(T) * width_ * height_);
    return clone;
  }

 private:
  // Disallow copy and assign.
  CameraSensorData(CameraSensorData&);
  void operator=(const CameraSensorData&);

  const int width_;
  const int height_;
  T* const data_;
};

// CameraSensor interface
class CameraSensor {
 public:
  using T = float;

  // Creates a new CameraSensor (specifically of type CameraSensorImpl) by
  // reading binary data from file @filename.
  static std::unique_ptr<CameraSensor> New(std::string filename);

  virtual ~CameraSensor() {}

  // Returns width (in pixels) of images that this sensor captures.
  virtual int GetSensorWidth() const = 0;

  // Returns height (in pixels) of images that this sensor captures.
  virtual int GetSensorHeight() const = 0;

  // Sets the state of the virtual camera's lens cap. If the lens cap is on,
  // then all calls to GetSensorData() will return data for a "dark frame".
  // Note that dark frame data will still have noise and sensor defect
  // artifacts.
  virtual void SetLensCap(bool lens_cap) = 0;

  // Set the magnitude of random noise added to all sensor output buffers
  virtual void SetNoiseMagnitude(float max) = 0;

  // Returns an RGB image corresponding to a "perfectly" processed version of
  // the output of the sensor.  @width, and @height specify a crop window of
  // pixels to access, and the size of the resulting CameraSensorData structure
  // is the size of this crop window (not necessarily the size of the sensor).
  virtual std::unique_ptr<Image<RgbPixel>> GetPerfectImage(
      int left, int top, int width, int height) const = 0;

  // Returns a 2D array corresponding to the raw output of the sensor. @left, @top,
  // @width, and @height specify a crop window of pixels to access, and the size
  // of the resulting CameraSensorData structure is the size of this crop window
  // (not necessarily the size of the sensor).
  virtual std::unique_ptr<CameraSensorData<T>> GetSensorData(
      int left, int top, int width, int height) const = 0;

  // Returns a vector of 2D arrays corresponding to a burst of readouts from
  // the raw sensor output. @left, @top, @width, and @height specify a crop window
  // of pixels to access, and the size of the resulting CameraSensorData structure
  // is the size of this crop window (not necessarily the size of the sensor). 
  virtual std::vector<std::unique_ptr<CameraSensorData<T>>> GetBurstSensorData(
      int left, int top, int width, int height) const = 0;
};

// An implementation of the CameraSensor interface which provides sensor data
// obtained as a set of raw images. 
class CameraSensorImpl : public CameraSensor {
 public:
  using T = typename CameraSensor::T;
  struct SensorPlane {
    T* buffer;  // does not own.
  };
  struct Opts {
    T dead_pixel_value = 10000.f;
    T row_gain_min = 0.f;
    T row_gain_max = 0.f;
    T noise_magnitude = 0.f;
  };

  CameraSensorImpl(int width,
                   int height,
                   const T* buffer,
                   std::vector<SensorPlane> planes,
                   std::vector<Image<RgbPixel>*> perfect_images,
                   Opts opts);
  ~CameraSensorImpl() {
    delete[] buffer_;
    for (auto& image : perfect_images_) delete image;
    std::vector<Image<RgbPixel>*>().swap(perfect_images_);
  }
  int GetSensorWidth() const override { return width_; }
  int GetSensorHeight() const override { return height_; }
  void SetLensCap(bool lens_cap) override { lens_cap_ = lens_cap; }
  void SetNoiseMagnitude(float mag) override { opts_.noise_magnitude = mag; }
  std::unique_ptr<Image<RgbPixel>> GetPerfectImage(
      int left, int top, int width, int height) const override;
  std::unique_ptr<CameraSensorData<T>> GetSensorData(
      int left, int top, int width, int height) const override;
  std::vector<std::unique_ptr<CameraSensorData<T>>> GetBurstSensorData(
      int left, int top, int width, int height) const override;

 private:
  const int width_;
  const int height_;
  const T* const buffer_;  // owns.
  const std::vector<SensorPlane> planes_;
  std::vector<Image<RgbPixel>*> perfect_images_;  // owns pointers.
  Opts opts_;
  bool lens_cap_ = false;
  mutable int active_sensor_plane_ = 0;  // start with first plane by default.
  std::map<int, float> bright_lines_;
  std::set<std::array<int, 2>> dead_pixels_;
};
