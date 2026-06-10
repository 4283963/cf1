package com.pet.transfer.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.pet.transfer.entity.LivePet;
import com.pet.transfer.entity.TransferRequest;

import java.util.List;

public interface TransferRequestService extends IService<TransferRequest> {

    TransferRequest createTransfer(TransferRequest request);

    TransferRequest approveTransfer(Long id, String approver);

    TransferRequest rejectTransfer(Long id, String approver);

    List<TransferRequest> listWithStoreNames();

    TransferRequest shipTransfer(Long id, String shipper, String driver, int estimatedHours);

    TransferRequest completeTransfer(Long id);

    List<TransferRequest> listShipping();

    List<LivePet> listPetsInTransfer(Long transferId);
}
